import sys


a_size = int(sys.argv[1])
b_size = int(sys.argv[2])

verilog_output = open("PPM.v", 'w')
instance=0
col_depth = [0]*(a_size+b_size-1)

def get_col_depth(row):
   global col_depth
   print(col_depth[row])
   col_depth[row] += 1
   return col_depth[row]-1

   
def reset_depth():
   global col_depth
   col_depth= [0]*(a_size+b_size-1)

def FA(instance, a, b, cin, out, cout):
    verilog_output.write(f"\tFA FA_{instance} (.a({a}), .b({b}), .cin({cin}), .out({out}), .cout({cout}));\n")

def HA(instance, a, b, out, cout):
    verilog_output.write(f"\tHA HA_{instance} (.a({a}), .b({b}), .out({out}), .cout({cout}));\n")

def FA_module():
    verilog_output.write("""module FA(input a, input b, input cin, output out, output cout);
\tassign {cout, out} = a+b+cin;
endmodule\n\n""")

def HA_module():
    verilog_output.write("""module HA(input a, input b, output out, output cout);
\tassign {cout, out} = a+b;
endmodule\n\n""")

def count_bits_in_columns(a_size, b_size):
    columns = [0] * (a_size + b_size -1)
    for i in range(a_size):
        for j in range(b_size):
            columns[i + j] += 1
    return columns

def PartialProductGeneration(a_size, b_size):
    #Generate partial products
    for i in range(a_size):
        for j in range(b_size-1):
            verilog_output.write(f"\twire stage_0_{str(get_col_depth(j+i))}_{str(j+i)} = a[{str(i)}]&b[{str(j)}];\n")
        verilog_output.write(f"\twire stage_0_{str(get_col_depth(b_size-1+i))}_{str(b_size-1+i)} = a[{str(i)}]&~b[{str(b_size-1)}];\n")
        verilog_output.write(f"\twire stage_0_{str(get_col_depth(b_size-1+i))}_{str(b_size-1+i)} = 1'b1;\n")
    #for i in range(a_size):
    #verilog_output.write("\n")
    reset_depth()

# Complete this
#def Reduce(stage, column, rows):
    #if 1 bit, use wire and assign to next stage directly
    #if 2 bits but column is less than half of a_size+b_size, use wire and assign both to next stage directly
    #if 2 bits but column is greater than half of a_size+b_size, use HA and assignt next stage
    #if 3 bits but column position is less than half of a_size+b_size, use HA and assign remaining bit to next stage
    #else use FA and HA to reduce to 2 rows (can take multiple stages)

def Reduce(stage, column, rows):
  global instance
  if rows == 1:
    # Single bit, use wire and assign directly
    verilog_output.write(f"\twire stage_{stage+1}_0_{column} = stage_{stage}_0_{column};\n")
  elif rows == 2:
    # Two bits, check column position
    if column < (a_size + b_size - 1) // 2:
      # Less than half, use wire for both
      verilog_output.write(f"\twire stage_{stage+1}_0_{column} = stage_{stage}_0_{column};\n")
      verilog_output.write(f"\twire stage_{stage+1}_1_{column} = stage_{stage}_1_{column};\n")
    else:
      # Greater than half, use HA
      HA(instance, f"stage_{stage}_0_{column}", f"stage_{stage}_1_{column}", f"stage_{stage+1}_0_{column}", f"stage_{stage+1}_1_{column}")
      instance += 1
  else:
    # Three or more bits, use FA and HA for reduction
    cin = "1'b0"  # Initial carry-in
    for i in range(rows):
      if i == 0:
        a_term = f"stage_{stage}_0_{column}"
      else:
        a_term = f"stage_{stage}_1_{column - i}"
      b_term = f"stage_{stage}_0_{column + i}"
      FA(instance, a_term, b_term, cin, f"stage_{stage+1}_0_{column - i}", f"stage_{stage+1}_1_{column}")
      cin = f"cout"  # Propagate carry-out for next iteration
      instance += 1
    # Handle potential final carry-out
    verilog_output.write(f"\twire stage_{stage+1}_1_{column} = cout;\n")

#Change this as necessary
def PartialProductReduction(a_size, b_size):
    stage = 0
    for i in range(len(count_bits_in_columns(a_size, b_size))):
        Reduce(stage, i, count_bits_in_columns(a_size, b_size)[i])
            

def AssignOutputs(last_stage, a_size, b_size):
  """
  Assigns the partial product bits to the output wires.

  Args:
      last_stage: Last stage of reduction.
      a_size: Size of input a.
      b_size: Size of input b.
  """
  res1_string, res2_string = "", ""
  for i in range(a_size + b_size):
    res1_string = res1_string + f"stage_{last_stage}_0_{str(i)}, "
    res2_string = res2_string + f"stage_{last_stage}_1_{str(i)}, "
  
  # Remove extra comma and space at the end
  res1_string = res1_string[:-2]
  res2_string = res2_string[:-2]
  
  verilog_output.write(f"\tassign result1 = {{{res1_string}}};\n")
  verilog_output.write(f"\tassign result2 = {{{res2_string}}};\n")




# Create Module and declare ports
verilog_output.write(f"module mult(input [{str(a_size-1)}:0] a, input [{str(b_size-1)}:0] b, output [{str(a_size+b_size-1)}:0] result1, output [{str(a_size+b_size-1)}:0] result2);\n\n")

# Generate Partial Products
PartialProductGeneration(a_size, b_size)

# Reduce Partial Products
max_stage = PartialProductReduction(a_size, b_size)

#Assgn Outputs
AssignOutputs(max_stage, a_size, b_size)

#End Module
verilog_output.write("endmodule\n\n")
FA_module()
HA_module()

verilog_output.close()