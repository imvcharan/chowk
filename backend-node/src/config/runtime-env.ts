export function resolveRuntimeEnv(env: NodeJS.ProcessEnv = process.env): Record<string, string | undefined> {
  const nextEnv: Record<string, string | undefined> = { ...env };

  if (!nextEnv.JWT_ACCESS_SECRET && nextEnv.JWT_SECRET) {
    nextEnv.JWT_ACCESS_SECRET = nextEnv.JWT_SECRET;
  }

  if (!nextEnv.JWT_SECRET && nextEnv.JWT_ACCESS_SECRET) {
    nextEnv.JWT_SECRET = nextEnv.JWT_ACCESS_SECRET;
  }

  return nextEnv;
}
