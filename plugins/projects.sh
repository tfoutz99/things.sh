#!/bin/bash

myPluginID=$(getNextPluginID)
myPlugin="plugin$myPluginID"
myPluginCommand="projects"
myPluginDescription="Shows $limitBy projects ordered by '$orderBy'"
myPluginMethod="queryProjects"

eval "$myPlugin=('$myPluginCommand' '$myPluginDescription' '$myPluginMethod')"

queryProjects() {
  sqlite3 "$THINGSDB" "$(getProjectsQuery)"
}

getProjectsQuery() {
    read -rd '' query <<-SQL || true
SELECT
  CASE 
    WHEN AREA.title IS NOT NULL THEN AREA.title 
    WHEN PROJECT.title IS NOT NULL THEN PROJECT.title
    WHEN HEADING.title IS NOT NULL THEN HEADING.title
    ELSE "(No Context)"
  END,
  TASK.title
FROM $TASKTABLE as TASK
LEFT OUTER JOIN $TASKTABLE PROJECT ON TASK.project = PROJECT.uuid
LEFT OUTER JOIN $AREATABLE AREA ON TASK.area = AREA.uuid
LEFT OUTER JOIN $TASKTABLE HEADING ON TASK.actionGroup = HEADING.uuid
WHERE TASK.$ISNOTTRASHED AND TASK.$ISOPEN AND TASK.$ISPROJECT
ORDER BY TASK.$orderBy
LIMIT $limitBy
SQL
  echo "${query}"
}