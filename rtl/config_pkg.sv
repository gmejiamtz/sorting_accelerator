package config_pkg;

typedef enum logic [2:0] {
    INIT,
    PC,
    MR,
    BA,
    READ,
    WRITE,
    SR
} state_t;

endpackage
