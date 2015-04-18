module hw1test;
reg A; //input A
reg B; //input B
wire nA;
wire nB;
wire nAandnB;
wire AnorB;
wire AnandB;
wire nAornB;
not Ainv(nA, A); //top inverter produces signal nA and takes signal A, and is named Ainv
not Binv(nB, B); //inverter produces signal nB and takes signal B, and is named Binv
and andgate(nAandnB, nA, nB); //and gate produces nAandnB from nA nB
nor norgate(AnorB, A, B);
or orgate(nAornB, nA, nB);
nand nandgate(AnandB, A, B);

initial begin
$display("A B |~A ~B| ~(AB) ~A+~B | ~A~B ~(A+B)");
A = 0; B = 0; #1 //set A and B, wait for update(#1)
$display("%b %b | %b  %b|   %b      %b  |  %b     %b", A, B, nA, nB, AnandB, nAornB, nAandnB, AnorB);
A = 0; B = 1; #1 //set A and B, wait for new update
$display("%b %b | %b  %b|   %b      %b  |  %b     %b", A, B, nA, nB, AnandB, nAornB, nAandnB, AnorB);
A = 1; B = 0; #1 //set A and B, wait for new update
$display("%b %b | %b  %b|   %b      %b  |  %b     %b", A, B, nA, nB, AnandB, nAornB, nAandnB, AnorB);
A = 1; B = 1; #1 //set A and B, wait for new update
$display("%b %b | %b  %b|   %b      %b  |  %b     %b", A, B, nA, nB, AnandB, nAornB, nAandnB, AnorB);
end
endmodule
