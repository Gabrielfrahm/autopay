import { APIGatewayProxyEventV2, APIGatewayProxyResult } from 'aws-lambda';

export const handler = async (
  event: APIGatewayProxyEventV2
): Promise<APIGatewayProxyResult> => {
  try {
    const data = event.body ? JSON.parse(event.body) : {};

    console.log("Headers:", event.headers);
    console.log("Method:", event.requestContext.http.method);
    console.log("Payload:", data);

    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        dataReceived: data,
      }),
    };
  } catch (error) {
    return {
      statusCode: 400,
      body: JSON.stringify({
        success: false,
        message: JSON.stringify(error),
      }),
    };
  }
};
