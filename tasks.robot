*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.FileSystem
Library    RPA.Archive
Library    OperatingSystem
*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website


*** Keywords ***
Open the robot order website
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}    
    Open Available Browser     https://robotsparebinindustries.com/    maximized=${True}
    Wait Until Keyword Succeeds    10    1    Click Element    xpath://*[@id="root"]/header/div/ul/li[2]/a    
    ${orders}    Get orders
        FOR    ${order}    IN    @{orders}
            Close the annoying modal
            TRY
                Fill the form    ${order}
            EXCEPT    
                Reload Page
                Continue For Loop
            END
        END
        @{files}=    Find Files    pattern=*.pdf
        ${command}=    Catenate    SEPARATOR=    zip -j    zip_output    *.pdf
        Run    ${command}

Close the annoying modal
    Wait Until Keyword Succeeds    10    1    Click Button    OK

Get orders 
    ${orders}    Read table from CSV    orders.csv
    [Return]    ${orders}

Fill the form 
    [Arguments]    ${row}
    ${head_option}    Evaluate    ${row}[Head] + 1
    Wait Until Keyword Succeeds    10    1    Click Element    xpath://*[@id="head"]/option[${head_option}]
    Wait Until Keyword Succeeds    10    1    Click Element    xpath://*[@id="id-body-${row}[Body]"]
    Wait Until Keyword Succeeds    10    1    Input Text    class:form-control    ${row}[Legs]
    Wait Until Keyword Succeeds    10    1    Input Text    xpath://*[@id="address"]    ${row}[Address]
    Wait Until Keyword Succeeds    10    1    Click Button    xpath://*[@id="preview"]   
    Click Element   xpath://*[@id="order"]  
    Sleep    2
    Wait Until Keyword Succeeds    10    1    RPA.Browser.Selenium.Screenshot
    ...    xpath://*[@id="robot-preview-image"]
    ...    ${OUTPUT_DIR}${/}Robot_${row}[Order number].png
    ${table_html}=    Get Element Attribute    xpath://*[@id="receipt"]    outerHTML
    HTML To PDF    ${table_html}    ${OUTPUT_DIR}${/}Robot_Receipt${row}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}Robot_Receipt${row}[Order number].png
    Click Element    xpath://*[@id="order-another"]
    Add Files To Pdf    ${OUTPUT_DIR}${/}Robot_Receipt${row}[Order number].png    ${OUTPUT_DIR}${/}Robot_Receipt${row}[Order number].pdf   