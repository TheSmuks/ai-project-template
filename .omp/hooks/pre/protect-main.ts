/**
 * .omp/hooks/pre/protect-main.ts
 * 
 * Pre-hook: Protect main branch from direct commits/pushes
 * 
 * Subscribes to: tool_call (bash)
 * Purpose: Blocks direct commits or pushes to main branch
 * 
 * This hook enforces the PR-only convention. When an agent attempts
 * to commit directly to main or push to main, it blocks the operation
 * and instructs the user to use a pull request instead.
 * 
 * HOW TO ADAPT:
 * - To block other branches, add to the protectedBranches array
 * - To allow specific users/roles, add permission checks
 * - To auto-redirect to feature branch, modify the redirect logic
 */

// Import OMP types for hook lifecycle events
import { OmpPreHook, ToolCallEvent, BashToolCall } from '@oh-my-pi/sdk';

/**
 * Protected branches that require PR workflow
 */
const PROTECTED_BRANCHES = ['main', 'master'];

/**
 * Git commands that would modify protected branches
 */
const PROTECTED_COMMANDS = [
  'git push origin',
  'git push -u origin',
  'git push -f origin',
  'git commit --amend',
  'git merge',
];

/**
 * Pattern to match branch names in git commands
 */
const BRANCH_PATTERN = /\b(main|master|release\/[\d.]+|production|staging)\b/g;

/**
 * Check if a command targets a protected branch
 */
function targetsProtectedBranch(command: string): boolean {
  const lowerCommand = command.toLowerCase();
  
  // Check if command is a protected git operation
  const isProtectedOperation = PROTECTED_COMMANDS.some(
    (op) => lowerCommand.startsWith(op.toLowerCase())
  );
  
  if (!isProtectedOperation) {
    return false;
  }
  
  // Extract branch name from command
  // Common patterns:
  //   git push origin main
  //   git push origin HEAD:main
  //   git push -f origin main
  //   git push origin --force main
  const branchMatch = lowerCommand.match(/\b(main|master|release\/[\d.]+|production|staging)\b/);
  
  if (branchMatch) {
    return PROTECTED_BRANCHES.includes(branchMatch[1]);
  }
  
  return false;
}

/**
 * Extract the branch being targeted from a command
 */
function extractTargetBranch(command: string): string | null {
  const lowerCommand = command.toLowerCase();
  
  // Try to match branch name at end of push command
  const pushMatch = lowerCommand.match(
    /(?:push(?: -u|-f)?|--force)\s+(?:origin\s+)?(?:HEAD:?)?(\S+)$/
  );
  
  if (pushMatch) {
    return pushMatch[1];
  }
  
  // Check if command mentions a protected branch inline
  const branchMatch = lowerCommand.match(BRANCH_PATTERN);
  if (branchMatch) {
    return branchMatch[1];
  }
  
  return null;
}

/**
 * The pre-hook implementation
 * 
 * This function is called before a bash tool call executes.
 * Return true to allow the call, false to block it.
 * 
 * @param event - The tool call event containing command details
 * @returns true to allow, false to block
 */
export const protectMain: OmpPreHook = async (event: ToolCallEvent): Promise<boolean> => {
  // Only process bash tool calls
  if (event.tool !== 'tool:bash') {
    return true;
  }
  
  const bashCall = event as BashToolCall;
  const command = bashCall.arguments.command || '';
  
  // Check if this command targets a protected branch
  if (!targetsProtectedBranch(command)) {
    return true; // Allow non-protected commands
  }
  
  const targetBranch = extractTargetBranch(command);
  
  if (!targetBranch) {
    return true; // Allow if we can't determine the branch
  }
  
  // Block the operation and provide guidance
  console.warn(`[protect-main] BLOCKED: Protected branch '${targetBranch}' target detected`);
  console.warn(`[protect-main] Command: ${command}`);
  console.warn(`[protect-main] Direct changes to protected branches are not allowed.`);
  console.warn(`[protect-main] Please create a feature branch and use a pull request instead.`);
  console.warn(`[protect-main] Suggested: git checkout -b feature/<name> && ${command.replace(/main|master/, 'feature/<name>')}`);
  
  return false; // Block the operation
};

/**
 * Hook metadata
 */
export const metadata = {
  name: 'protect-main',
  description: 'Prevents direct commits/pushes to protected branches',
  version: '1.0.0',
  events: ['tool_call'],
  toolFilter: ['tool:bash'],
};

/**
 * Default export for OMP hook loader
 */
export default protectMain;
