function [] = WriteMotor(cmd, port)
    command = cmd;
    
    writeline(port, command);
    flush(port); 
    pause(0.1);

    end