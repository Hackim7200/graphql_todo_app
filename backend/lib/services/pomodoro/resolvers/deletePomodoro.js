import { util } from "@aws-appsync/utils";
import * as ddb from "@aws-appsync/utils/dynamodb";

export function request(ctx) {
  const PK = `USER#${ctx.identity.sub}`;
  const SK = `TODO#${ctx.args.todoId}#POMODORO#${ctx.args.id}`;
  return ddb.remove({ key: { PK, SK } });
}

export function response(ctx) {
  if (ctx.error) util.error(ctx.error.message, ctx.error.type);
  if (!ctx.result) util.error("Pomodoro not found", "NotFound");
  const { PK, SK, __typename, ...pomodoro } = ctx.result;
  return pomodoro;
}
