import { util } from "@aws-appsync/utils";
import * as ddb from "@aws-appsync/utils/dynamodb";

export function request(ctx) {
  const identity = ctx.identity;
  const now = util.time.nowISO8601();
  const id = ctx.args.input.id; // id is given by the client, no need to generate

  const PK = `USER#${identity.sub}`;
  const SK = `TODO#${id}`;

  const item = {
    __typename: "Todo",
    PK,
    SK,
    id: ctx.args.input.id,
    owner: identity.sub,
    title: ctx.args.input.title,
    isCompleted: ctx.args.input.isCompleted ?? false,
    createdAt: now,
    updatedAt: now,
  };

  return ddb.put({
    key: { PK, SK },
    item,
  });
}

export function response(ctx) {
  if (ctx.error) util.error(ctx.error.message, ctx.error.type);
  const { PK, SK, __typename, ...todo } = ctx.result;
  return todo;
}
