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
              "PoolId": "eu-west-2:aa61fcf2-d366-44dd-9f5b-e99f9878687c",
              "Region": "eu-west-2"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "eu-west-2_iuQLDQPgj",
            "AppClientId": "7559r7tun6lvgmfqsdvjni2ds",
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
          "endpoint": "https://j895lge6rh.execute-api.eu-west-2.amazonaws.com/prod/",
          "region": "eu-west-2",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        },
        "PomodoroPlansGraphQLApi": {
          "endpointType": "GraphQL",
          "endpoint": "https://d2ajcwzd35bstjzzsevh3nzday.appsync-api.eu-west-2.amazonaws.com/graphql",
          "region": "eu-west-2",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  }
}
''';
// datastack is not added here since its accessed via lambda apigateway