/**
 * .omp/hooks/post/template-compliance-hint.ts
 * 
 * Post-hook: Template Compliance Hints
 * 
 * Subscribes to: tool_call (write/edit)
 * Purpose: After modifying template-critical files, hints at compliance checks
 * 
 * This hook logs a reminder to run the audit script when certain
 * template-critical files are modified. It helps ensure that changes
 * to the template remain compliant with the template specification.
 * 
 * HOW TO ADAPT:
 * - Add your project's critical file patterns to CRITICAL_PATTERNS
 * - Customize the hint message for your project's audit command
 * - Add tool integrations for notification (Slack, etc.)
 */

// Import OMP types for hook lifecycle events
import { OmpPostHook, ToolCallEvent, WriteEditToolCall } from '@oh-my-pi/sdk';

/**
 * File patterns that indicate template-critical changes
 */
const CRITICAL_PATTERNS = [
  /AGENTS\.md$/,
  /CHANGELOG\.md$/,
  /\.github\/workflows\//,
  /ARCHITECTURE\.md$/,
  /CONTRIBUTING\.md$/,
  /\.omp\/.*\.md$/,
  /SKILL\.md$/,
  /SETUP_GUIDE\.md$/,
  /ADOPTING\.md$/,
];

/**
 * Pattern to audit command mappings
 * Maps file patterns to relevant audit checks
 */
const AUDIT_CHECKS: Record<string, string[]> = {
  'AGENTS.md': ['required-sections', 'build-commands', 'commit-conventions'],
  'CHANGELOG.md': ['changelog-format', 'unreleased-section'],
  '.github/workflows': ['workflow-syntax', 'required-workflows'],
  'ARCHITECTURE.md': ['diagram-valid', 'component-list'],
  '.omp/rules': ['rule-syntax', 'rule-uniqueness'],
  '.omp/hooks': ['hook-syntax', 'hook-events'],
  '.omp/skills': ['skill-frontmatter', 'skill-structure'],
  'SKILL.md': ['skill-frontmatter', 'skill-structure'],
};

/**
 * Check if a file path matches critical patterns
 */
function isCriticalFile(filePath: string): boolean {
  const normalizedPath = filePath.toLowerCase();
  return CRITICAL_PATTERNS.some((pattern) => pattern.test(normalizedPath));
}

/**
 * Determine which audit checks are relevant for a file
 */
function getRelevantAuditChecks(filePath: string): string[] {
  const checks: string[] = [];
  
  for (const [pattern, patternChecks] of Object.entries(AUDIT_CHECKS)) {
    if (filePath.toLowerCase().includes(pattern.toLowerCase())) {
      checks.push(...patternChecks);
    }
  }
  
  return [...new Set(checks)]; // Deduplicate
}

/**
 * Build the hint message for the user
 */
function buildHintMessage(filePath: string, auditChecks: string[]): string {
  const fileName = filePath.split('/').pop() || filePath;
  
  const lines = [
    ``,
    `[template-compliance-hint] File modified: ${fileName}`,
    ``,
    `Consider running the audit script to verify compliance:`,
    ``,
    `  bash .omp/skills/template-guide/scripts/audit.sh`,
    ``,
  ];
  
  if (auditChecks.length > 0) {
    lines.push(`Relevant checks: ${auditChecks.join(', ')}`);
    lines.push(``);
  }
  
  // Add specific guidance based on file type
  if (filePath.includes('AGENTS.md')) {
    lines.push(`Tip: Ensure all required sections are filled with actual values.`);
    lines.push(`      See docs/agent-files-guide.md for section requirements.`);
  } else if (filePath.includes('CHANGELOG.md')) {
    lines.push(`Tip: Verify your entry is under [Unreleased] and uses correct category.`);
    lines.push(`      See keepachangelog.com for format guidance.`);
  } else if (filePath.includes('.github/workflows')) {
    lines.push(`Tip: CI workflows should pass lint and validation before merging.`);
  } else if (filePath.includes('.omp/')) {
    lines.push(`Tip: OMP extensions should follow the format specification.`);
    lines.push(`      See docs/omp-extensions-guide.md for type-specific guidance.`);
  }
  
  return lines.join('\n');
}

/**
 * The post-hook implementation
 * 
 * This function is called after a write/edit tool call completes.
 * It cannot modify the result but can log or take async actions.
 * 
 * @param event - The tool call event containing operation details
 */
export const templateComplianceHint: OmpPostHook = async (
  event: ToolCallEvent
): Promise<void> => {
  // Only process write and edit tool calls
  if (event.tool !== 'tool:write' && event.tool !== 'tool:edit') {
    return;
  }
  
  const toolCall = event as WriteEditToolCall;
  const filePath = toolCall.arguments.path;
  
  // Check if this file is critical
  if (!isCriticalFile(filePath)) {
    return; // Skip non-critical files
  }
  
  // Get relevant audit checks
  const auditChecks = getRelevantAuditChecks(filePath);
  
  // Build and log the hint message
  const message = buildHintMessage(filePath, auditChecks);
  console.log(message);
  
  // Optionally send via OMP message system for notification
  // (Uncomment if you want external notifications)
  // await omp.sendMessage({
  //   to: '#team-channel',
  //   message: `Template file modified: ${filePath}\nRun audit.sh to verify compliance.`,
  // });
};

/**
 * Hook metadata
 */
export const metadata = {
  name: 'template-compliance-hint',
  description: 'Suggests audit runs after template-critical file changes',
  version: '1.0.0',
  events: ['tool_call'],
  toolFilter: ['tool:write', 'tool:edit'],
};

/**
 * Default export for OMP hook loader
 */
export default templateComplianceHint;
