

%macro  pushx 1-*
  %rep  %0
    push    %1
  %rotate 1
  %endrep
%endmacro

%macro  popx 1-*

  %rep %0
  %rotate -1
    pop     %1
  %endrep

%endmacro
