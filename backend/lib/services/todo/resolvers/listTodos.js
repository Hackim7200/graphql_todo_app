import { util } from "@aws-appsync/utils";
import * as ddb from "@aws-appsync/utils/dynamodb";

export function request(ctx) {
  const sub = ctx.identity.sub;
  return ddb.query({
    query: {
      PK: { eq: `USER#${sub}` },
      SK: { beginsWith: "TODO#" },
    },
    limit: ctx.args.limit ?? 200,
    nextToken: ctx.args.nextToken,
  });
}

export function response(ctx) {
  if (ctx.error) util.error(ctx.error.message, ctx.error.type);

  const rows = ctx.result?.items ?? [];
  const items = rows.map((row) => {
    const { PK, SK, __typename, ...todo } = row;
    return todo;
  });

  return {
    items,
    nextToken: ctx.result?.nextToken ?? null,
  };
}
