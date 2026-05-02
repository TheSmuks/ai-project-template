/**
 * .omp/tools/template-audit/index.ts
 * 
 * Custom Agent Tool: Template Audit
 * 
 * Purpose: Exposes the template audit script as a first-class callable tool
 * 
 * This tool wraps .omp/skills/template-guide/scripts/audit.sh and returns
 * structured results that the agent can programmatically interpret.
 * 
 * WHY THIS PATTERN:
 * - Wraps an existing script without reinventing logic
 * - Provides structured output instead of raw text
 * - Makes the audit accessible by name rather than bash path
 * - Demonstrates how to expose custom capabilities as OMP tools
 */

// Import OMP types for tool definition
import { OmpTool, OmpToolResult } from '@oh-my-pi/sdk';

/**
 * Tool input parameters
 */
export interface TemplateAuditInput {
  /**
   * Whether to attempt automatic fixes for detected issues
   * @default false
   */
  fix?: boolean;
  
  /**
   * Specific checks to run (defaults to all)
   * Options: file-structure, required-files, placeholders, format, yaml-frontmatter
   */
  checks?: string[];
  
  /**
   * Output format
   * @default "summary"
   */
  format?: 'summary' | 'detailed' | 'json';
}

/**
 * Individual check result
 */
export interface CheckResult {
  name: string;
  status: 'pass' | 'fail' | 'warn' | 'skip';
  message: string;
  filePath?: string;
  suggestions?: string[];
}

/**
 * Audit result structure
 */
export interface TemplateAuditResult {
  success: boolean;
  totalChecks: number;
  passed: number;
  failed: number;
  warnings: number;
  checks: CheckResult[];
  summary: string;
}

/**
 * Default checks to run
 */
const DEFAULT_CHECKS = [
  'file-structure',
  'required-files',
  'placeholders',
  'format',
  'yaml-frontmatter',
];

/**
 * Run the audit script and parse output
 */
async function runAudit(fix: boolean, checks: string[]): Promise<string> {
  const args = [];
  
  if (fix) {
    args.push('--fix');
  }
  
  if (checks.length > 0) {
    args.push('--checks', checks.join(','));
  }
  
  const auditPath = '.omp/skills/template-guide/scripts/audit.sh';
  const argsStr = args.length > 0 ? ` ${args.join(' ')}` : '';
  
  // Note: In actual OMP, you'd use the built-in bash executor
  // This is a placeholder showing the intended pattern
  const command = `bash ${auditPath}${argsStr}`;
  
  return command; // Actual execution would return stdout
}

/**
 * Parse audit output into structured results
 */
function parseAuditOutput(output: string, format: string): TemplateAuditResult {
  // This is a simplified parser - actual implementation would
  // parse the real audit.sh output format
  
  const lines = output.split('\n').filter(Boolean);
  const checks: CheckResult[] = [];
  
  for (const line of lines) {
    // Parse lines like:
    // [PASS] file-structure: Required directories exist
    // [FAIL] placeholders: Found 3 placeholder comments
    // [WARN] format: CHANGELOG.md uses old format
    
    const match = line.match(/\[(PASS|FAIL|WARN|SKIP)\]\s+(\w+):\s+(.+)/);
    if (match) {
      const [, status, name, message] = match;
      checks.push({
        name,
        status: status.toLowerCase() as CheckResult['status'],
        message,
      });
    }
  }
  
  const passed = checks.filter((c) => c.status === 'pass').length;
  const failed = checks.filter((c) => c.status === 'fail').length;
  const warnings = checks.filter((c) => c.status === 'warn').length;
  
  return {
    success: failed === 0,
    totalChecks: checks.length,
    passed,
    failed,
    warnings,
    checks,
    summary: `Audit ${failed === 0 ? 'passed' : 'failed'}: ${passed}/${checks.length} checks passed, ${warnings} warnings`,
  };
}

/**
 * The template audit tool implementation
 * 
 * This function is called when the agent invokes the tool by name.
 * It should return structured results the agent can interpret.
 * 
 * @param input - Tool input parameters
 * @returns Structured audit results
 */
export const templateAuditTool: OmpTool<TemplateAuditInput, TemplateAuditResult> = async (
  input: TemplateAuditInput
): Promise<OmpToolResult<TemplateAuditResult>> => {
  const { fix = false, checks: inputChecks, format = 'summary' } = input;
  
  // Use provided checks or default to all
  const checks = inputChecks && inputChecks.length > 0 
    ? inputChecks 
    : DEFAULT_CHECKS;
  
  try {
    // Run the audit script
    const output = await runAudit(fix, checks);
    
    // Parse and format results
    const result = parseAuditOutput(output, format);
    
    return {
      success: result.success,
      data: result,
    };
  } catch (error) {
    return {
      success: false,
      error: `Audit failed: ${error instanceof Error ? error.message : String(error)}`,
    };
  }
};

/**
 * Tool metadata and schema
 */
export const metadata = {
  name: 'template-audit',
  description: 'Runs the template compliance audit to verify project structure and format',
  category: 'verification',
  version: '1.0.0',
  parameters: {
    type: 'object',
    properties: {
      fix: {
        type: 'boolean',
        description: 'Attempt automatic fixes for detected issues',
        default: false,
      },
      checks: {
        type: 'array',
        items: { type: 'string' },
        description: 'Specific checks to run (defaults to all)',
        default: ['file-structure', 'required-files', 'placeholders', 'format', 'yaml-frontmatter'],
      },
      format: {
        type: 'string',
        enum: ['summary', 'detailed', 'json'],
        description: 'Output format for results',
        default: 'summary',
      },
    },
  },
  examples: [
    {
      description: 'Run full audit with summary output',
      input: {},
    },
    {
      description: 'Run specific checks only',
      input: {
        checks: ['placeholders', 'format'],
      },
    },
    {
      description: 'Run audit with auto-fix',
      input: {
        fix: true,
      },
    },
  ],
};

/**
 * Default export for OMP tool loader
 */
export default templateAuditTool;
