#!/bin/bash

myPluginID=$(getNextPluginID)
myPlugin="plugin$myPluginID"
myPluginCommand="completed"
myPluginDescription="Shows $limitBy completed tasks ordered by '$orderBy'"
myPluginMethod="queryCompleted"

eval "$myPlugin=('$myPluginCommand' '$myPluginDescription' '$myPluginMethod')"

queryCompleted() {
  sqlite3 "$THINGSDB" "$(getCompletedQuery)"
}

getCompletedQuery() {
    read -rd '' query <<-SQL || true
SELECT
  CASE 
    WHEN AREA.title IS NOT NULL THEN AREA.title 
    WHEN PROJECT.title IS NOT NULL THEN PROJECT.title
    WHEN HEADING.title IS NOT NULL THEN HEADING.title
    ELSE "(No Context)"
  END,
TASK.title
FROM $TASKTABLE TASK
LEFT OUTER JOIN $TASKTABLE PROJECT ON TASK.project = PROJECT.uuid
LEFT OUTER JOIN $AREATABLE AREA ON TASK.area = AREA.uuid
LEFT OUTER JOIN $TASKTABLE HEADING ON TASK.actionGroup = HEADING.uuid
WHERE TASK.$ISNOTTRASHED AND TASK.$ISTASK
AND TASK.$ISCOMPLETED
ORDER BY TASK.$orderBy
LIMIT $limitBy
SQL
  echo "${query}"
}