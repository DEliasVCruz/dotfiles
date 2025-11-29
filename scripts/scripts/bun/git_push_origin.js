import { $ } from "bun";
import { parseArgs } from "util";
import { fatal } from "./utils/io";

import "./utils/colors";

const FATAL_ERROR =
  "Could not push upstream, ".red() + "failed with error:".cyan();

const { values } = parseArgs({
  args: Bun.argv,
  options: {
    force: {
      type: "boolean",
    },
  },
  strict: true,
  allowPositionals: true,
});

let push_options = values.force ? "-f" : "";

let current_branch = await $`git branch --show-current`
  .text()
  .then((value) => value.trim())
  .catch((err) => fatal(FATAL_ERROR, err.stderr.toString()));

console.log("Working with branch", current_branch.cyan());

const upstream_branch =
  await $`git rev-parse --abbrev-ref ${current_branch}@\{upstream\} | grep origin`
    .text()
    .then((value) => {
      const branch = value.trim();
      if (!branch) {
        throw new Error("no upstream configured for branch");
      }

      return "";
    })
    .catch((err) => {
      const errStr = err.stderr?.toString() ?? err.toString();

      if (errStr.includes("no upstream configured for branch")) {
        console.log(
          "No remote tracking branch found".cyan(),
          `\nRemote branch set to track ${`\origin/${current_branch}`.cyan()}`,
        );

        push_options = "";

        return `-u origin ${current_branch}`;
      }

      fatal(FATAL_ERROR, err.stderr.toString());
    });

const message = `Pushing to upstream ${`\origin/${current_branch}`.cyan()}`;
console.log(message);
// process.stdout.write(message);

// let progress = 0;
// const progressInterval = setInterval(() => {
//   process.stdout.write("\b".repeat(message.length + 14 + (progress % 3)));
//   progress++;

//   process.stdout.write(message + ".".repeat(progress % 3).cyan());
// }, 500);

// console.log("The command", `git push ${push_options} ${upstream_branch}`);
await $`git push ${{ raw: push_options.trim() }} ${{ raw: upstream_branch.trim() }}`
  .quiet()
  .then(() => {
    // clearInterval(progressInterval);
    // console.log("\nBranch successfully pushed upstream!".green());
    console.log("Branch successfully pushed upstream!".green());
  })
  .catch((err) => {
    fatal(FATAL_ERROR, err.stderr.toString());
  });
