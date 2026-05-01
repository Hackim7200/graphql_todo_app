import { util } from "@aws-appsync/utils";
import * as ddb from "@aws-appsync/utils/dynamodb";

export function request(ctx) {
  const identity = ctx.identity;
  const input = ctx.args.input;
  const now = util.time.nowISO8601();

  const PK = `USER#${identity.sub}`;
  const SK = `TODO#${input.id}`;

  const update = { updatedAt: now };
  if (input.title !== undefined) {
    update.title = input.title;
  }
  if (input.isCompleted !== undefined) {
    update.isCompleted = input.isCompleted;
  }

  return ddb.update({ key: { PK, SK }, update });
}

export function response(ctx) {
  if (ctx.error) util.error(ctx.error.message, ctx.error.type);
  const { PK, SK, __typename, ...todo } = ctx.result;
  return todo;
}
