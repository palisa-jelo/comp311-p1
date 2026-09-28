# COMP 311 Lab Answers

Your name:

- Nathaniel
- Stoner

Replace every `[REPLACED]` and `TBD` below before submission.

---

# Part 1: You Are the Compiler

## 1. RV32I translation

Also place your completed code in `starter/part1.s`.

```asm
addi t1, x0, 1;
sll t1, t1, 2;
add t1, t1, t0; # index of 1
addi t2, x0, 3;
sll t2, t2, 2;
add t2, t2, t0; # index of 3
lw t1, 0(t1); # values[1]
lw t2, 0(t2); # values[3]
add t3, t1, t2; # their sum
addi t3, t3, 5; # add 5
```

## 2. Which instructions access memory?

The 7th and 8th instructions, which were loadword instructions

## 3. Why are the array offsets measured in bytes rather than array indices?

Assembly needs to know how many bytes to jump forward. It doesn't have know how many bytes to skip based on just indicies because it wouldn't have the information of piece of data in the array being 4 bytes (in this example)

## 4. What is the minimum number of RISC-V instructions needed?

It could be done in 4 if I hard-coded in the byte offsets an just had the last 4 lines

---

# Part 2: Predict Before You Compile

## 1. Which version do you predict will require less machine work?

The bit shift in scale_shift would probably require less machine work

## 2. Why?

because there's less operations, so it's not doing addition 8 times.

## 3. What do you expect the machine-level instructions to do differently?

The machine level instruction for scale_add.c would likely do a whole bunch of addi/add, while the scale_shift can do a sll.

---

# Part 3: Compile to RV32I

## Annotated assembly excerpts

### `scale_add`, `-O0`

```asm
	.file	"scale_add.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	scale_add
	.type	scale_add, @function
scale_add:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	zero,-20(s0)
	sw	zero,-24(s0)
	j	.L2
.L3:
	lw	a4,-20(s0)
	lw	a5,-36(s0)
	add	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L2:
	lw	a4,-24(s0)
	li	a5,7
	ble	a4,a5,.L3
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	scale_add, .-scale_add
	.ident	"GCC: (13.2.0-11ubuntu1+12) 13.2.0"
```

### `scale_shift`, `-O0`

```asm
	.file	"scale_shift.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	scale_shift
	.type	scale_shift, @function
scale_shift:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	slli	a5,a5,3
	mv	a0,a5
	lw	s0,28(sp)
	addi	sp,sp,32
	jr	ra
	.size	scale_shift, .-scale_shift
	.ident	"GCC: (13.2.0-11ubuntu1+12) 13.2.0"
```

### `scale_add`, `-O2`

```asm
	.file	"scale_add.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	scale_add
	.type	scale_add, @function
scale_add:
	slli	a0,a0,3
	ret
	.size	scale_add, .-scale_add
	.ident	"GCC: (13.2.0-11ubuntu1+12) 13.2.0"
```

### `scale_shift`, `-O2`

```asm
	.file	"scale_shift.c"
	.option nopic
	.attribute arch, "rv32i2p1"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.align	2
	.globl	scale_shift
	.type	scale_shift, @function
scale_shift:
	slli	a0,a0,3
	ret
	.size	scale_shift, .-scale_shift
	.ident	"GCC: (13.2.0-11ubuntu1+12) 13.2.0"
```

## Instruction counts

| Version | Optimization | Total static instructions in function | Loads / Stores | Arithmetic / Logic | Branches / Jumps |
|---|---:|---:|---:|---:|---:|
| `scale_add` | `-O0` | 22 | 12 | 7 | 3 |
| `scale_shift` | `-O0` | 10 | 4 | 5 | 1 |
| `scale_add` | `-O2` | 2 | 0 | 1 | 1 |
| `scale_shift` | `-O2` | 2 | 0 | 1 | 1 |

## 1. What major differences do you observe between `-O0` and `-O2`?

The optimised version didn't have the stack pointer moving at all, and just changed the value and returned. The unoptimised versions had to all the stack stuff, put the result in a register (a5) before then moving it into the register where the result was supposed to go (a0)

## 2. What happened to the repeated-addition loop under optimization?

It got turned into a shift logical left! no more loop

## 3. Did the optimized versions become more similar?

The optimised versions were exactly the same except for the names of things

## 4. Was your original prediction still meaningful after optimization?

I was correct about shifting left being the most efficient way, I just didn't know that the addition loop in C code would be optimised into it and assumed it would just be slower by default

---

# Part 4: Static vs. Dynamic Instruction Count

## 1. Identify the loop body and paste the relevant assembly.

```asm
	lw	a4,-20(s0)
	lw	a5,-36(s0)
	add	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
```

## 2. How many static instructions are in the loop body?

7

## 3. How many times does the loop execute?

8

## 4. How many dynamic instruction executions are caused by the loop body?

Show your reasoning.

Assuming we're not counting the .L2 part that is the loop condition and only the body, we have 8 runs of 7 lines each for 56 dynamic instructions

## 5. Why is this different from the static instruction count?

The same lines of code are run multiple times, so the number of instructions run is greater than the number of lines

---

# Part 5: Array Indexing vs. Pointer Iteration

## Prediction

### 1. Which version do you predict will require less machine work?

I'd suspect that the program with the pointer will require a bit less machine work.

### 2. What do you expect the assembly for each version to do differently?

Incrementing the pointer seems like an easier task than incrementing i, shifting left by 2, and then using that as the offset, which is what I imagine them doing.

## Investigation

### 3. In `sum_indexed`, where is the array element address computed?

```asm
Here:
.L3:
	lw	a5,-24(s0)
	slli	a5,a5,2
```

Explanation:

i is loaded in from the stack, and then multiplied by 4 for the offset in bytes

### 4. In `sum_pointer`, how does the pointer change each iteration?

```asm
The pointer is increased by 4 in each iteration by this line:
	addi	a5,a5,4
```

Explanation:

Each loop will load the value into a5 by grabbing from -36(s0), add 4, and then save it back to -36(s0)

### 5. At `-O0`, which version appears to require more machine work? What evidence are you using?

The array_indexed version has around 3 more lines of code in the loop, so it probably requires more machine work.

### 6. At `-O2`, how similar are the two generated implementations?

They are pretty similar, having almost the same number of lines and basically the same instructions. The main difference is that the indexed version checks if the pointer in a5 ever reaches the end of the array elements we are reading and breaks after it does while adding 4 every time, while the pointer version adds 4 until it's > the end.

### 7. Is pointer-based C automatically faster than indexed C?

It looks like no!

### 8. What does this tell you about source-level performance claims?

Depending on how well things are optimised, sometimes we can't draw conclusions on how well things will perform since it may just not matter.

---

# Part 6: Modification Experiment

## Prediction

### 1. Do you predict the static instruction count will increase or decrease? Why?

The static instruction could will certainly increase because there are more caculations for it to do, adding another 4 to the byte count for i and then loading the value at a+(i+1)

### 2. Do you predict the number of loop iterations will increase or decrease?

The number of loop iterations has to decrease because we are iterating by two each time, i += 2. So it should execute about half as many times.

### 3. Do you predict the dynamic instruction count will increase or decrease? Why?

I think the dynamic instruction count in the non-optimised version may decrease because it's looping less times and in each loop it was loading from memory what i was. In the optimised version though, it should be just about the same, since we're incrementing the pointer less with less loops but also have to increment a temporary value for a+(i+1).

## Results

### 4. Did the static instruction count increase or decrease?

Increase

### 5. Did the number of loop iterations increase or decrease?

Decrease

### 6. Did your estimated dynamic instruction count increase or decrease?

Show your reasoning.

I thought it would decrease, but it looks like it just about stayed the same. The loop went from 10 lines to 19 lines, so if the loop runs half as many times, it saves just a couple of lines worth of instructions. (9.5 ~~ 10)

### 7. Why can static and dynamic instruction counts move in different directions?

Programs may have less instructions (fewer static instructions) but loop through those few instructions a lot more times (more dynamic instructions), or the other way around.

### 8. Did the optimizer preserve your source-level transformation?

It did! You can see the two paris of load words and the two times that these values from the array are added--

Optional short assembly excerpt used as evidence:

```asm
	lw	a2,0(a5)
	lw	a3,4(a5)
	addi	a5,a5,8
	add	a0,a0,a2
	add	a0,a0,a3
```

---

# Part 7: Performance Claim Investigation

## 1. Before compiling, predict what assembly each version will produce.

The mult8.c will probably use "mul" while the shift8 will use "slli something, something, 3" to do this product.

## 2. Are the generated instructions different at `-O0`?

Surprisingly, no they are the exact same! Both use slli

Relevant excerpt(s):

```asm
shift8:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	slli	a5,a5,3

and

mul8:
	addi	sp,sp,-32
	sw	s0,28(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	lw	a5,-20(s0)
	slli	a5,a5,3
```

## 3. Are they different at `-O2`?

They are again exactly the same, mainly just cutting out things for stack pointers.

Relevant excerpt(s):

```asm
mul8:
	slli	a0,a0,3
	ret
	.size	mul8, .-mul8
	.ident	"GCC: (13.2.0-11ubuntu1+12) 13.2.0"
```

## 4. Does manually replacing multiplication by 8 with a shift necessarily improve performance?

Nope!

## 5. What role does the compiler play in evaluating source-level optimization advice?

The complier can look for easy optimisations to make such as shifting bits instead of multiplying/dividing by a multiple of two.

---

# Part 8: Final Reflection

Answer each in 2–4 sentences.

## 1. What was the most surprising difference between the C code and the generated RISC-V?

The RISC-V code when unoptimised loaded data into temporary registers a lot. This makes sense since we don't want to alter the value of things passed into a function, I just don't ever think of how many times this has to be done with for loops and method calls in C.

## 2. Why is dynamic instruction count often more informative than static instruction count?

If we have a couple of lines of code that are looped MANY times, then the static count is somewhat meaningless if we want to actually know how many lines of instructions our machine performed.

## 3. Why might fewer instructions still not guarantee a proportionally faster program?

Load and store instructions take more time than arithmetic instructions, so having fewer instructions may not be faster if it's these heavy-load instructions.

## 4. Looking across Parts 2–7, what did compiler optimization change most dramatically?

Use examples from at least two earlier parts.

The most drastic change was removing the prologue and epilogue of a lot of these functions that just did a bit of simple math. Dealing with the stack pointer and saving/loading everything took up a lot of lines, almost all of lines sometimes. For example, in shift8, it's just 2-3 lines of actual calculations while the stack needs another 7 for the epilogue and prologue

## 5. What evidence would you want before accepting a claim that one C implementation is "faster"?

We could look at the assembly and check the number of times instructions are done dynamically and how of these are loads/stores as opposed to arithmetic instructions. If I knew all of the optimisations that the compiler did, I could make an educated guess, but that's unrealistic. It would just be easier to run the program and time it probably.