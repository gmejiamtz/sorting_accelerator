# Memory Controller State Machine 
## IDLE:
    out = 0111 (NOP)
    CKE = 1
    if (SR timeUp):
        out = 0001
        CKE = 0
        go to SR
    else if (go):
        out = 0010
        go to state PC
    else:
        out = 0111
        stay in IDLE

## PC:
    out = 0111 
    start t_RP delay
    if (delay done):
        if (SR timeUp):
            go to SR
            out = 0001
            CKE = 0
        else:
            go to SMR
            out = 0000
    else:
        stay in PC

## MR: 
    out = 0111
    start t_RSC delay
    if (delay done):
        go to BA
        out = 0011
    else:
        stay in SMR
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
        go to IDLE
        read ready = 1
        out = ???? (Might be DCs)
    else if (read done & cas delay not done):
        stay in READ
        begin cas delay
    else:
        stay in READ

## WRITE:
    out = 0111
    if (write done):
        write valid = 1
        go to IDLE
        out = ????
    else:
        stay in WRITE

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