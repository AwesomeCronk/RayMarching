import numpy as np
import pyopencl as cl
import simpleANSI as ansi

print('creating context')
clContext = cl.create_some_context(interactive=False)
print('creating queue')
clQueue = cl.CommandQueue(clContext)
print('created them both')
with open('renderKernel.cl', 'r') as kernelSourceFile:
    kernelSource = kernelSourceFile.read()

program = cl.Program(clContext, kernelSource).build()
print(type(program.render))


# a_np = np.random.rand(50000).astype(np.float32)

# a_cl = cl.Buffer(clContext, mf.READ_ONLY | mf.COPY_HOST_PTR, hostbuf=a_np)
# b_cl = cl.Buffer(clContext, mf.READ_ONLY | mf.COPY_HOST_PTR, hostbuf=b_np)

pixels_cl = cl.Buffer(clContext, cl.mem_flags.WRITE_ONLY, 20 * 20 * 4 * 4)
kernel = program.render  # Use this Kernel object for repeated calls
kernel(clQueue, (20 * 20,), None, pixels_cl)

pixels_np = np.ndarray((20 * 20 * 4,), np.int32)
cl.enqueue_copy(clQueue, pixels_np, pixels_cl)

# print(pixels_np[0:4])

for y in range(20):
    for x in range(20):
        i = (20 * y + x)
        r, g, b = pixels_np[4 * i:4 * i + 3]
        # print(r, g, b)
        print(ansi.graphics.setGraphicsMode(
            ansi.graphics.bgColor,
            ansi.graphics.mode16Bit,
            r,
            g,
            b
        ), end=' ')
    print('\x1b[39;49m')    # Reset colors
