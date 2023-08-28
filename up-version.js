import fs from 'fs'

const minorUp = process.argv.length === 3

const filePath = "index.js";
const regexPattern = /const version = '(\d+)\.(\d+)\.(\d+)'/g

// Read the content of the file
fs.readFile(filePath, "utf-8", (err, data) => {
  if (err) {
    console.error("Error reading the file:", err)
    return
  }

  // Modify the content
  const modifiedContent = data.replace(
    regexPattern,
    (match, major, minor, patch) => {
      let newPatch = parseInt(patch)
      let newMinor = parseInt(minor)
      if (minorUp) {
        newMinor = parseInt(minor) + 1
        newPatch = 0
      } else {
        newPatch = parseInt(patch) + 1
      }
      return `const version = '${major}.${newMinor}.${newPatch}'`
    }
  )

  // Write the modified content back to the file
  fs.writeFile(filePath, modifiedContent, "utf-8", (err) => {
    if (err) {
      console.error("Error writing to the file:", err)
      return
    }
    console.log("Line replacement complete.")
  })
})
