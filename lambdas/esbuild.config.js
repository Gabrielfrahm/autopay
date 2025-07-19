const esbuild = require("esbuild");
const path = require("path");
const fs = require("fs");

const lambdas = [
  "transaction",
  "autopay",
];

lambdas.forEach((lambdaName) => {
  esbuild.build({
    entryPoints: [path.join(__dirname, lambdaName, "handler.ts")],
    bundle: true,
    platform: "node",
    target: "node22",
    outfile: path.join(__dirname, "..", "dist", lambdaName, "handler.js"),
    minify: true,
  }).catch(() => process.exit(1));
});