xquery version "1.0-ml";

declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace ls = "info:lc/xq/load-stats";

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Statistics for daily Voyager bib loads into natlibcat</title>
        <style type="text/css">table, th, td &#x7b; border: 1px solid #DFDFDF; &#x7d;</style>
    </head>
    <body>
        <h1 style="text-align: center;">Daily statistics for natlib Voyager bib loads</h1>
        <table style="margin: auto; text-align: center; width: 900px;">
            <tr style="height: 40px; background-color: #DFDFDF;">
                <th>Date/Time</th>
                <th>Source</th>
                <th>Batch job</th>
                <th>Total</th>
                <th>New</th>
                <th>Change</th>
                <th>Increase</th>
                <th>Error</th>
                <th>Unknown</th>
            </tr>
            {
                for $res in /ls:load-results
                order by $res/ls:datetime descending
                return 
                    <tr style="height: 30px;">
                        <td>{$res/ls:datetime/string()}</td>
                        <td>{$res/ls:source/string()}</td>
                        <td>{$res/ls:batch/string()}</td>
                        <td>{$res/ls:total-processed/string()}</td>
                        <td>{$res/ls:new/string()}</td>
                        <td>{$res/ls:change/string()}</td>
                        <td>{$res/ls:increase/string()}</td>
                        <td>{$res/ls:error/string()}</td>
                        <td>{$res/ls:unknown/string()}</td>
                    </tr>        
            }
        </table>
    </body>
</html>