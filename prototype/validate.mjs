import fs from "node:fs";

const html = fs.readFileSync(new URL("./index.html", import.meta.url), "utf8");
const css = fs.readFileSync(new URL("./styles.css", import.meta.url), "utf8");
const js = fs.readFileSync(new URL("./app.js", import.meta.url), "utf8");

const ids = [...html.matchAll(/id="([^"]+)"/g)].map((match) => match[1]);
const duplicateIds = ids.filter((id, index) => ids.indexOf(id) !== index);
if (duplicateIds.length) throw new Error(`Duplicate IDs: ${duplicateIds.join(", ")}`);

const routes = [
  "launch", "welcome", "signup", "login", "path", "create", "join", "invite",
  "library", "masterclass", "player", "account", "loading", "offline", "server"
];
const missingRoutes = routes.filter((route) => !js.includes(`case "${route}"`));
if (missingRoutes.length) throw new Error(`Missing routes: ${missingRoutes.join(", ")}`);

if (/https?:\/\//.test(`${html}\n${css}\n${js}`)) {
  throw new Error("Unexpected external runtime URL found");
}

const openBraces = (css.match(/{/g) || []).length;
const closeBraces = (css.match(/}/g) || []).length;
if (openBraces !== closeBraces) throw new Error("CSS braces are unbalanced");

for (const reference of html.matchAll(/(?:src|href)="([^"]+)"/g)) {
  const target = reference[1];
  if (target.startsWith("#")) continue;
  if (!fs.existsSync(new URL(target, new URL("./index.html", import.meta.url)))) {
    throw new Error(`Missing local reference: ${target}`);
  }
}

console.log("Prototype validation passed: 15 routes, unique IDs, local assets, and balanced CSS.");
