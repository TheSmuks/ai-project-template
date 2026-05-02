/**
 * .omp/tools/template-audit/index.ts
 *
 * Custom Agent Tool: Template Audit
 *
 * Purpose: Exposes the template audit script as a first-class callable tool
 *
 * This tool wraps .omp/skills/template-guide/scripts/audit.sh and returns
 * structured results that the agent can programmatically interpret.
 */

import { Type } from "@sinclair/typebox";
import type { AgentToolResult } from "@oh-my-pi/sdk";

/**
 * Default checks to run
 */
const DEFAULT_CHECKS = [
  "file-structure",
  "required-files",
  "placeholders",
  "format",
  "yaml-frontmatter",
] as const;

/**
 * Input parameters for the template audit tool
 */
type TemplateAuditParams = {
  fix?: boolean;
  checks?: string[];
  format?: "summary" | "detailed" | "json";
};

/**
 * Individual check result
 */
interface CheckResult {
  name: string;
  status: "pass" | "fail" | "warn" | "skip";
  message: string;
  filePath?: string;
  suggestions?: string[];
}

/**
 * Audit result structure
 */
interface TemplateAuditResult {
  success: boolean;
  totalChecks: number;
  passed: number;
  failed: number;
  warnings: number;
  checks: CheckResult[];
  summary: string;
}

/**
 * Parse audit output into structured results
 */
function parseAuditOutput(output: string): TemplateAuditResult {
  const lines = output.split("\n").filter(Boolean);
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
        status: status.toLowerCase() as CheckResult["status"],
        message,
      });
    }
  }

  const passed = checks.filter((c) => c.status === "pass").length;
  const failed = checks.filter((c) => c.status === "fail").length;
  const warnings = checks.filter((c) => c.status === "warn").length;

  return {
    success: failed === 0,
    totalChecks: checks.length,
    passed,
    failed,
    warnings,
    checks,
    summary: `Audit ${failed === 0 ? "passed" : "failed"}: ${passed}/${checks.length} checks passed, ${warnings} warnings`,
  };
}

/**
 * Run the audit script and return structured results
 *
 * Note: audit.sh does not support --fix, --checks, or --format flags.
 * This tool runs the audit with all checks unconditionally.
 */
async function runAudit(
  exec: (command: string) => Promise<{ stdout: string; stderr: string; exitCode: number }>
): Promise<TemplateAuditResult> {
  const auditPath = ".omp/skills/template-guide/scripts/audit.sh";
  const { stdout, stderr, exitCode } = await exec(`bash ${auditPath}`);

  if (exitCode !== 0 && stderr) {
    throw new Error(stderr);
  }

  return parseAuditOutput(stdout);
}

/**
 * CustomToolFactory: creates the template-audit tool for OMP
 *
 * This factory function is called by OMP's CustomToolLoader with a shared API
 * that provides access to OMP's capabilities (exec, typebox, etc.).
 */
function createTemplateAuditTool(
  api: {
    exec: (command: string) => Promise<{ stdout: string; stderr: string; exitCode: number }>;
    typebox: typeof Type;
  }
) {
  return {
    name: "template-audit",
    label: "Template Audit",
    description:
      "Runs the template compliance audit to verify project structure and format",
    parameters: Type.Object(
      {
        // Note: --fix, --checks, and --format flags are not supported by audit.sh
        // The audit always runs all checks unconditionally
      },
      { additionalProperties: false }
    ),
    async execute(
      _toolCallId: string,
      _params: TemplateAuditParams,
      _signal?: AbortSignal,
      _onUpdate?: (partial: AgentToolResult<unknown>) => void
    ): Promise<AgentToolResult<TemplateAuditResult>> {
      try {
        const result = await runAudit(api.exec);

        return {
          content: [{ type: "text", text: JSON.stringify(result, null, 2) }],
          details: result,
        };
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        return {
          content: [
            {
              type: "text",
              text: `Audit failed: ${message}`,
            },
          ],
          details: {
            success: false,
            error: message,
          },
        };
      }
    },
  };
}

export default createTemplateAuditTool;
