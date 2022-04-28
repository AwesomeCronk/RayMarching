import numpy as np
import pyopencl as cl
import PIL.Image, sys, time
import simpleANSI as ansi

# print('creating context')
clContext = cl.create_some_context(interactive=False)
# print('creating queue')
clQueue = cl.CommandQueue(clContext)
# print('created them both')
with open('renderKernel.cl', 'r') as kernelSourceFile:
    kernelSource = kernelSourceFile.read()

program = cl.Program(clContext, kernelSource).build()


# a_np = np.random.rand(50000).astype(np.float32)

# a_cl = cl.Buffer(clContext, mf.READ_ONLY | mf.COPY_HOST_PTR, hostbuf=a_np)
# b_cl = cl.Buffer(clContext, mf.READ_ONLY | mf.COPY_HOST_PTR, hostbuf=b_np)

resX = int(sys.argv[1]); resY = int(sys.argv[2])

# Numpy arrays
res_np = np.ndarray((2,), np.int32)
res_np[0] = resX; res_np[1] = resY

# CL arrays
pixels_cl = cl.Buffer(clContext, cl.mem_flags.WRITE_ONLY, resX * resY * 4 * 4)
res_cl = cl.Buffer(clContext, cl.mem_flags.COPY_HOST_PTR, hostbuf=res_np)

# Run the CL kernel
kernel = program.render  # Use this Kernel object for repeated calls
t0 = time.perf_counter_ns()
kernel(clQueue, (resX * resY,), None, pixels_cl, res_cl)
t1 = time.perf_counter_ns()
print('Render time: {}ms'.format((t1 - t0) / 1000000))

# Numpy arrays from CL arrays
pixels_np = np.ndarray((resX * resY * 4,), np.int32)
cl.enqueue_copy(clQueue, pixels_np, pixels_cl)


def renderTerminal():
    for y in range(resY):
        for x in range(resX):
            i = (resX * y + x)
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

def renderPIL():
    image = PIL.Image.new(mode='RGB', size=(resX, resY))
    pixels_pil = image.load()

    for y in range(resY):
        for x in range(resX):
            i = (resX * y + x)
            pixels_pil[x, y] = tuple(pixels_np[4 * i:4 * i + 3])

    image.show()

renderPIL()
