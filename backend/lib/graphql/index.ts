import * as fs from "fs";
import * as path from "path";
import type {
  ISchema,
  ISchemaConfig,
  SchemaBindOptions,
} from "aws-cdk-lib/aws-appsync";

/** Order matters: schema root mapping (base.graphql), then shared notes, then domain types. */
const MERGE_ORDER = [
  "base.graphql",
  "shared.graphql",
  "pomodoro.graphql",

  "todos.graphql",

] as const;

export function mergeSchemas(): string {
  const schemaDir = path.join(__dirname, "schemas");
  return MERGE_ORDER.map((file) =>
    fs.readFileSync(path.join(schemaDir, file), "utf-8").trimEnd(),
  ).join("\n\n");
}

/** Writes `merged.graphql` next to this module (useful for clients / codegen). */
export function writeMergedGraphqlSchema(): void {
  const outPath = path.join(__dirname, "merged.graphql");
  fs.writeFileSync(outPath, `${mergeSchemas()}\n`, "utf-8");
}

export const appSyncMergedSchema: ISchema = {
  bind(
    api: Parameters<ISchema["bind"]>[0],
    _options?: SchemaBindOptions,
  ): ISchemaConfig {
    const apiId = (api as unknown as { apiId: string }).apiId;
    return { apiId, definition: mergeSchemas() };
  },
};
