export const BEDROCK_MODEL_MAP: Record<string, string> = {
  "claude-opus-4-7": "global.anthropic.claude-opus-4-7",
  "claude-opus-4-6": "global.anthropic.claude-opus-4-6-v1",
  "claude-sonnet-4-6": "global.anthropic.claude-sonnet-4-6",
  "claude-haiku-4-5": "global.anthropic.claude-haiku-4-5-20251001-v1:0",
};

export function isBedrockEnabled(): boolean {
  const value = process.env.CLAUDE_CODE_USE_BEDROCK;
  return value === "1" || value?.toLowerCase() === "true";
}
