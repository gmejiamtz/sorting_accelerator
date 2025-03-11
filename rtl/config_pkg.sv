package config_pkg;

typedef enum logic [2:0] {
    INIT,
    PC_ACTIV,
    MR,
    BA,
    READ,
    WRITE,
    PC_DEACTIV,
    SR
} state_t;

endpackage
