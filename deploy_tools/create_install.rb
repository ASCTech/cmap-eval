# Running this script will generate in the directory named "deploy" all of the important files necessary to actually 
# deploy the application.

require "fileutils"

DEPLOY = "deploy"
DEPLOY_TOOLS = "deploy_tools"
SOURCE = "src"

PATH_FIXER = "path_fixer.bat"

# A helper to make paths relative to the root easier.
def rel relative_path
  return File.dirname(__FILE__) + "/../" + relative_path
end

# Destroy the deploy directory, so we can start fresh.
if File.exist? rel DEPLOY
  FileUtils.rm_r rel DEPLOY
end

# Create the new deploy folder.
Dir.mkdir rel DEPLOY

# Copy the source folder in.
FileUtils.cp_r rel(SOURCE), rel(DEPLOY)

# Copy everything in deploy_tools in.
FileUtils.cp_r rel(DEPLOY_TOOLS + "/."), rel(DEPLOY)