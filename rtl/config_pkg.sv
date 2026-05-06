
package config_pkg;

// define structs and enums needed for design
typedef enum logic [3:0] {
    idle,
    size,
    load,
    sort,   
    write_back,
    write_back_done,    //if the sorter is done done
    transmit_left_bracket,
    bram_read,  //using sync mem requies the extra state
    bram_data_valid, //sync data is only valid for one cycle after ir being read
    transmit_raw_int,
    transmit_comma,
    error
} state_t;

//ERROR CODE STRINGS
localparam error_code_timeout = 32'h45_3A_31_0A; //"E:1\n"
localparam error_code_bad_header = 32'h45_3A_32_0A; //"E:2\n"
localparam error_code_bad_size = 32'h45_3A_33_0A; //"E:3\n"
localparam error_code_unknown = 32'h45_3A_34_0A; //"E:4\n"

//PUNC STRINGS
localparam left_bracket_string = 32'h00_00_0a_5b; //string '\0\0\n\['
localparam right_bracket_string = 32'h5d_0a_00_00; //string '\]\n\0\0'
localparam comma_string = 32'h00_00_00_2c; //string '\0\0\0\,'

//header string
localparam header_string = 32'h6c_6f_61_64;

endpackage
