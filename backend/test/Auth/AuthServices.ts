import { Amplify } from "aws-amplify";
import { SignInOutput, fetchAuthSession, signIn } from "@aws-amplify/auth";
import { CognitoIdentityClient } from "@aws-sdk/client-cognito-identity";
import { fromCognitoIdentityPool } from "@aws-sdk/credential-providers";

// Values updated from lib/outputs.json ("AuthStack-PomodoroPlans")
const USER_POOL_ID = "eu-west-2_vp6FqciTk";
const USER_POOL_CLIENT_ID = "6irk04c58fed8tr8upero9f9um";
const IDENTITY_POOL_ID = "eu-west-2:f70c4a4f-5bc7-449e-918a-eefdc30aed4d";
const AWS_REGION = "eu-west-2";

Amplify.configure({
  Auth: {
    Cognito: {
      userPoolId: USER_POOL_ID,
      userPoolClientId: USER_POOL_CLIENT_ID,
    },
  },
});

export class AuthService {
  public async login(userName: string, password: string) {
    const signInOutput: SignInOutput = await signIn({
      username: userName,
      password: password,
      options: {
        authFlowType: "USER_PASSWORD_AUTH",
      },
    });
    return signInOutput;
  }

  /**
   * call only after login
   */
  public async getIdToken() {
    const authSession = await fetchAuthSession();
    return authSession.tokens?.idToken?.toString();
  }
}
