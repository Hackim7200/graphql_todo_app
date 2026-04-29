const String amplifyconfig = '''
{
  "version": "1",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "eu-west-2:f70c4a4f-5bc7-449e-918a-eefdc30aed4d",
              "Region": "eu-west-2"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "eu-west-2_vp6FqciTk",
            "AppClientId": "6irk04c58fed8tr8upero9f9um",
            "Region": "eu-west-2"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "usernameAttributes": ["EMAIL"],
            "signupAttributes": ["EMAIL"],
            "passwordProtectionSettings": {
              "passwordPolicyMinLength": 8,
              "passwordPolicyCharacters": [
                "REQUIRES_LOWERCASE",
                "REQUIRES_UPPERCASE",
                "REQUIRES_NUMBERS"
              ]
            }
          }
        }
      }
    }
  },
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "PomodoroPlansApi": {
          "endpointType": "REST",
          "endpoint": "https://osrafl3fyj.execute-api.eu-west-2.amazonaws.com/prod/",
          "region": "eu-west-2",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        },
        "PomodoroPlansGraphQLApi": {
          "endpointType": "GraphQL",
          "endpoint": "https://coqaixyo6rg2bjmfbgefexyysm.appsync-api.eu-west-2.amazonaws.com/graphql",
          "region": "eu-west-2",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  }
}
''';
// datastack is not added here since its accessed via lambda apigateway