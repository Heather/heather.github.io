---
title: Read/Write Excel from F# with NPOI
---

[NPOI](https://npoi.codeplex.com/) is  is the .NET version of POI Java project at http://poi.apache.org/. POI is an open source project which can help you read/write xls, doc, ppt files. It has a wide application.

Let read some data from custom Excel file with

 - name `fname`
 - column `varCol`
 - from row `startRow`
 - to row `endRow`

Load file (here is possible to get sheet by name or by number)

``` fsharp
using(new FileStream(fname, FileMode.Open, FileAccess.Read)) <| fun fs ->
    let templateWorkbook = new HSSFWorkbook(fs, true)
    let sheet = templateWorkbook.GetSheetAt(0) //.GetSheet(shName)
```

There is small function to get column number from char and number

``` fsharp
let cXL name =  
    if name <> "" then
       (name.ToLower().ToCharArray()
        |> Seq.map   /> fun char -> Convert.ToInt32 char - 96
        |> Seq.sumBy (fun x -> x + 25)) - 26
    else 0
let cvar = cXL varCol
```

Load data

``` fsharp
let getData sr er =
    [ for i in sr..er -> try Double.Parse(sheet.GetRow(i-1).GetCell(cvar).ToString())
                         with _ -> 0.0 ]
let sr = try Int32.Parse startRow 
         with _ -> 0
let er = match endRow with
            | "0" -> let rec counter cn =
                        try ignore <| sheet.GetRow(cn).GetCell(cvar)
                            counter (cn+1)
                        with _ -> (cn-1) 
                     counter 0
            | _ -> try Int32.Parse endRow
                   with _ -> 0
getData sr er
```

To load data from all excel files in custom folder

``` fsharp
let xls = (new DirectoryInfo(".")).GetFiles()
          |> Seq.filter ( fun f -> f.Name.EndsWith(".xls") )
          |> Seq.map    ( fun f -> f.Name                  )
let xlsData col start fin = xls |> Seq.map(fun n -> load n col start fin)
```

That's all...

Writing data is same simple as reading:

``` fsharp
using(new MemoryStream()) <| fun ms ->  
    let templateWorkbook = new HSSFWorkbook()
    templateWorkbook.Write(ms)         
    let msA = ms.ToArray()
    using(new FileStream((@"X.xls"), FileMode.OpenOrCreate , FileAccess.Write))
    <| fun newF ->
        try newF.Write(msA,0,msA.Length)
            MessageBox.Show( "X.xls created, check the result" ) |> ignore
        with _ -> MessageBox.Show( "Can't write to file" )       |> ignore
```
