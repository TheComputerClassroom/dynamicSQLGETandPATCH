%dw 2.0 
output application/json
import makeDynamicWhere from dw::dynamicQueryFunctions
---
makeDynamicWhere(message.attributes.queryParams, "jobs")