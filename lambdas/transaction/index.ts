export const handler = async (
  event:any
): Promise<any> => {
   console.log("Received event:", JSON.stringify(event));

  return {
    statusCode: 200,
    body: JSON.stringify({ ok: true, event }),
    headers: {
      "Content-Type": "application/json"
    }
  }
};
