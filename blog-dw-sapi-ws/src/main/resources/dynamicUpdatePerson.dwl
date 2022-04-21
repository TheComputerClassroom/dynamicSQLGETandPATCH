%dw 2.0
output application/json
import makeDynamicUpdate from dw::dynamicQueryFunctions
---
makeDynamicUpdate(message.payload, "people")