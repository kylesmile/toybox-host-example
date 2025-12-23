import fs from "node:fs"
import * as esbuild from "esbuild"

const watchMode = process.argv.some(arg => arg === "--watch")

const engines = fs.readdirSync("./engines", { withFileTypes: true })
  .filter(file => file.isDirectory())
  .map(file => file.name)

const engineEntries = engines
  .filter(engineName => fs.existsSync(`./engines/${engineName}/app/javascript/application.js`))
  .map(engineName => ({ out: `${engineName}/application`, in: `engines/${engineName}/app/javascript/application.js` }))

const context = await esbuild.context({
  entryPoints: [
    { out: "application", in: "app/javascript/application.js" },
    ...engineEntries,
  ],
  outdir: "app/assets/builds/",
  bundle: true,
  sourcemap: true
})

if (watchMode) {
  await context.watch()
} else {
  await context.rebuild()
  await context.dispose()
}
