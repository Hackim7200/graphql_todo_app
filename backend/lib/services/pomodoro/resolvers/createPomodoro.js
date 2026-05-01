import { util } from "@aws-appsync/utils";
import * as ddb from "@aws-appsync/utils/dynamodb";

export function request(ctx) {
  const identity = ctx.identity;
  const now = util.time.nowISO8601();
  const input = ctx.args.input;
  const { todoId, id } = input;

  const PK = `USER#${identity.sub}`;
  const SK = `TODO#${todoId}#POMODORO#${id}`;

  const item = {
    __typename: "Pomodoro",
    PK,
    SK,
    todoId,
    id,
    owner: identity.sub,
    title: input.title,
    duration: input.duration,
    isCompleted: input.isCompleted ?? false,
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
  const { PK, SK, __typename, ...pomodoro } = ctx.result;
  return pomodoro;
}
