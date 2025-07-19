import { APIGatewayProxyEventV2, APIGatewayProxyResult } from 'aws-lambda';

export const handler = async (
  event: APIGatewayProxyEventV2
): Promise<APIGatewayProxyResult> => {
   console.log("Received event:", JSON.stringify(event));

  return {
    statusCode: 200,
    body: JSON.stringify({ ok: true, event }),
    headers: {
      "Content-Type": "application/json"
    }
  }
};