*** Settings ***
Library     RequestsLibrary
Library     Collections
Library     OperatingSystem
Library     Process

Resource    assignment4_low_level_keywords.robot

*** Variables ***
${max_iterations}   200
${sleep_time}       1
${URL}              http://127.0.0.1:4000


*** Keywords ***
Start server and create new session
    Start server
    Create new session

Create new session
    Create Session  assignment3  ${URL}

# Server init and shutdown
Start server
    Start Process     bash    run.sh  shell=True
    Set Local Variable    ${status}   FAIL
    FOR    ${i}    IN RANGE   ${max_iterations}
        Run  sleep ${sleep_time}
        ${status}  ${response}    Run Keyword And Ignore Error    GET   ${URL}/assignments
        IF  "${status}" == "PASS"
            IF  ${response.status_code} == 200
                Set Local Variable    ${status}   OK
                Exit For Loop
            END
        END
    END
    IF  "${status}" != "OK"
        Fail
    END

Shutdown server
    ${resp}=    POST On Session  assignment3    /shutdown
    [Return]    ${resp}



An assignment with name "${name}" does not exist in the system
    Delete assignment if exists    ${name}


An assignment with id "X", name "${name}", description "${descr}", price ${price} and status "${status}" exists in the system
    We create an assignment with name "${name}", description "${descr}", price ${price} and status "${status}"
    The assignment receives id "X"


An assignment with name ${name} should not exist in the system
    ${resp}=    Get by name    ${name}
    Status Should Be    404     ${resp}


The number of assignments in the system is "N"
    ${list}=    Get list of assignments
    ${num_items}=   Get length  ${list}
    Set test variable  ${prev_num_items}     ${num_items}


We create an assignment with name "${name}", description "${descr}", price ${price} and status "${status}"
    ${resp}=    Create assignment     ${name}     ${descr}    ${price}    ${status}
    Set test variable  ${last_resp}     ${resp}

The assignment receives id "X"
    ${id}=   Get From Dictionary     ${last_resp.json()}     id
    Set Test Variable    ${X_id}    ${id}

An assignment with id "X", name "${name}", description "${descr}", price ${price} and status "${status}" should exist
    ${resp}=    Get by name   ${name}
    ${assignments}=      Get From Dictionary    ${resp.json()}    assignment
    ${assignment}=      Get From List   ${assignments}   0
    Dictionary Should Contain Item    ${assignment}    id    ${X_id}
    Dictionary Should Contain Item    ${assignment}    name    ${name}
    Dictionary Should Contain Item    ${assignment}    description    ${descr}
    Dictionary Should Contain Item    ${assignment}    price    ${price}
    Dictionary Should Contain Item    ${assignment}    status    ${status}


The creation operation should be successful
    Status Should Be    200     ${last_resp}

Server response should have status code ${status}
    Status Should Be    ${status}     ${last_resp}

The number of assignments in the system should be "N+1"
    ${list}=    Get list of assignments
    ${num_items}=   Get length  ${list}
    Should be equal as integers     ${${prev_num_items}+1}    ${num_items}

The number of assignments in the system should be "N-1"
    ${list}=    Get list of assignments
    ${num_items}=   Get length  ${list}
    Should be equal as integers     ${${prev_num_items}-1}    ${num_items}

The number of assignments in the system should be "N"
    ${list}=    Get list of assignments
    ${num_items}=   Get length  ${list}
    Should be equal as integers     ${prev_num_items}    ${num_items}

We delete the assignment with name "${name}"
    ${resp}=    Delete assignment    ${name}
    Set test variable  ${last_resp}     ${resp}

We update the name of the assignment with name "${name}" to "${new_name}"
    ${resp}=    Update assignment    ${name}    ${new_name}
    Set test variable  ${last_resp}     ${resp}
