# Memory Controller State Machine 
## IDLE:
    out = 0111 (NOP)
    CKE = 1
    else if (go):
        out = 0010
        go to state PC
    else:
        out = 0111
        stay in IDLE

## PC_activ:
    out = 0111 
    start t_RP delay
    if (delay done):
        go to MR
        out = 0000
    else:
        stay in PC_activ

## MR: 
    out = 0111
    start t_RSC delay
    if (delay done):
        go to BA
        out = 0011
    else:
        stay in MR
        out = 0111

## BA:
    out = 0111
    start t_RCD delay
    if (delay done):
        if (write and write is ready):
            go to WRITE
            out = 0101
        else if (read and read is valid):
            go to READ
            out = 0100
    else:
        stay in BA
        out = 0111

## READ:
    out = 0111
    if (read done & cas delay done):
        go to PC2
        read ready = 1
        out = 0010
    else if (read done & cas delay not done):
        stay in READ
        begin cas delay
    else:
        stay in READ

## WRITE:
    out = 0111
    if (write done):
        write valid = 1
        go to PC2
        out = 0010
    else:
        stay in WRITE

## PC_deactiv:
    out = 0001
    start t_RP delay
    if (delay done):
        go to SR
        out = 0001
        CKE = 0
    else:
        stay in PC_deactiv


## SR:
    out = 0001
    CKE = 0
    start t_REF relay
    if (REF delay done):
        begin t_XSR delay
        if (XSR delay done):
            go to IDLE
            CKE = 1
        else:
            stay in SR
            out = 0001
            CKE = 0
    else:
        stay in SR
        out = 0001
        CKE = 0