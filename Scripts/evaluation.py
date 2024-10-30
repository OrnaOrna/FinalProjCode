import matplotlib.pyplot as plt
import numpy as np
from scipy.io import loadmat


PATH_MAIN = ""

def time_t_value(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    t_value = np.abs((a.mean(axis=0) - b.mean(axis=0)) /
                     np.sqrt(a.var(axis=0) / a.shape[0] + b.var(axis=0) / b.shape[0]))
    return t_value


def t_test_2nd_order(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    a = np.power(a - a.mean(axis=0), 2)
    b = np.power(b - b.mean(axis=0), 2)
    return time_t_value(a, b)


def evaluate(traces: np.ndarray, bit_arr: np.ndarray) -> np.ndarray:
    a = traces[bit_arr, :]
    b = traces[~bit_arr, :]
    t_value = time_t_value(a, b)
    return t_value


def evaluate_2nd_order(traces: np.ndarray, bit_arr: np.ndarray) -> np.ndarray:
    a = traces[bit_arr, :]
    b = traces[~bit_arr, :]
    t_value = t_test_2nd_order(a, b)
    return t_value


def path(pt, bits, rand, system):
    return f'{PATH_MAIN}/{pt}pt {bits}bit {system} {rand} rand 10000 TRACES 500 samples/traces_0.mat'


def path_more(traces, pt):
    return f'{PATH_MAIN}/{pt}pt 8bit conv 8 rand {traces} TRACES 500 samples/traces_0.mat'


def path_rambam(bits, rand):
    return f'{PATH_MAIN}/3pt {bits}bit rambam {rand} rand 20000 TRACES 5200 samples/traces_0.mat'


def test1():
    tests3 = np.ndarray(4)
    tests4 = np.ndarray(5)
    tests6 = np.ndarray(7)
    tests7 = np.ndarray(8)
    tests8 = np.ndarray(9)
    tests8weak = np.ndarray(9)

    tests3_2 = np.ndarray(4)
    tests4_2 = np.ndarray(5)
    tests6_2 = np.ndarray(7)
    tests7_2 = np.ndarray(8)
    tests8_2 = np.ndarray(9)
    tests8weak_2 = np.ndarray(9)

    for i in range(5):
        f = loadmat(path(0, 4, i, 'conv'))
        traces = f["power_traces"]
        traces = traces - traces.mean(axis=1)[:, np.newaxis]
        bit_arr = f["bit"].flatten() == 0
        t_value = evaluate(traces, bit_arr)
        tests4[i] = np.max(t_value)
        t_value_2 = evaluate_2nd_order(traces, bit_arr)
        tests4_2[i] = np.max(t_value_2)
    for i in range(9):
        f = loadmat(path(0, 8, i, 'conv'))
        traces = f["power_traces"]
        traces = traces - traces.mean(axis=1)[:, np.newaxis]
        bit_arr = f["bit"].flatten() == 0
        t_value = evaluate(traces, bit_arr)
        tests8[i] = np.max(t_value)
        t_value_2 = evaluate_2nd_order(traces, bit_arr)
        tests8_2[i] = np.max(t_value_2)
    for i in range(9):
        f = loadmat(path(0, 8, i, 'conv weak'))
        traces = f["power_traces"]
        traces = traces - traces.mean(axis=1)[:, np.newaxis]
        bit_arr = f["bit"].flatten() == 0
        t_value = evaluate(traces, bit_arr)
        tests8weak[i] = np.max(t_value)
        t_value_2 = evaluate_2nd_order(traces, bit_arr)
        tests8weak_2[i] = np.max(t_value_2)
    for i in range(7):
        f = loadmat(path(0, 6, i, 'conv'))
        traces = f["power_traces"]
        traces = traces - traces.mean(axis=1)[:, np.newaxis]
        bit_arr = f["bit"].flatten() == 0
        t_value = evaluate(traces, bit_arr)
        tests6[i] = np.max(t_value)
        t_value_2 = evaluate_2nd_order(traces, bit_arr)
        tests6_2[i] = np.max(t_value_2)
    for i in range(8):
        f = loadmat(path(0, 7, i, 'conv'))
        traces = f["power_traces"]
        traces = traces - traces.mean(axis=1)[:, np.newaxis]
        bit_arr = f["bit"].flatten() == 0
        t_value = evaluate(traces, bit_arr)
        tests7[i] = np.max(t_value)
        t_value_2 = evaluate_2nd_order(traces, bit_arr)
        tests7_2[i] = np.max(t_value_2)
    for i in range(4):
        f = loadmat(path(0, 3, i, 'conv'))
        traces = f["power_traces"]
        traces = traces - traces.mean(axis=1)[:, np.newaxis]
        bit_arr = f["bit"].flatten() == 0
        t_value = evaluate(traces, bit_arr)
        tests3[i] = np.max(t_value)
        t_value_2 = evaluate_2nd_order(traces, bit_arr)
        tests3_2[i] = np.max(t_value_2)

    plt.plot(tests8, label="d=8")
    plt.plot(tests4, label="d=4")
    plt.plot(tests6, label="d=6")
    plt.plot(tests7, label="d=7")
    plt.plot(tests3, label="d=3")
    plt.plot(tests8weak, label="d=8 w. weak Q")
    plt.title("maximal t-value for T=10000 traces vs no. of random bits per r")
    plt.xlabel("no. of random bits utilized per random polynomial")
    plt.ylabel("maximal t-value")
    plt.legend()
    plt.show()

    plt.plot(tests8_2, label="d=8")
    plt.plot(tests4_2, label="d=4")
    plt.plot(tests6_2, label="d=6")
    plt.plot(tests3_2, label="d=3")
    plt.plot(tests7_2, label="d=7")
    plt.plot(tests8weak_2, label="d=8 w. weak Q")
    plt.title("maximal 2nd order t-value for T=10000 traces vs no. of random bits per r")
    plt.xlabel("no. of random bits utilized per random polynomial")
    plt.ylabel("maximal 2nd-order t-value")
    plt.legend()
    plt.show()


def test2():
    for i in range(5):
        tests_fixed = np.ndarray(50)
        tests_random = np.ndarray(50)
        f_sys = loadmat(path(0, 4, i, 'sys'))
        f_conv = loadmat(path(0, 4, i, 'conv'))
        traces_sys = f_sys["power_traces"]
        traces_conv = f_conv["power_traces"]
        traces_sys = traces_sys - traces_sys.mean(axis=1)[:, np.newaxis]
        traces_conv = traces_conv - traces_conv.mean(axis=1)[:, np.newaxis]
        bit_arr_sys = f_sys["bit"].flatten() == 0
        bit_arr_conv = f_conv["bit"].flatten() == 0
        for j in range(50):
            traces_sys_cut = traces_sys[:200 * (j + 1), :]
            traces_conv_cut = traces_conv[:200 * (j + 1), :]
            bit_arr_sys_cut = bit_arr_sys[:200 * (j + 1)]
            bit_arr_conv_cut = bit_arr_conv[:200 * (j + 1)]
            t_value_fixed = time_t_value(traces_sys_cut[bit_arr_sys_cut, :], traces_conv_cut[bit_arr_conv_cut, :])
            t_value_random = time_t_value(traces_sys_cut[~bit_arr_sys_cut, :], traces_conv_cut[~bit_arr_conv_cut, :])
            tests_fixed[j] = np.max(t_value_fixed)
            tests_random[j] = np.max(t_value_random)
        plt.plot([200 * (j + 1) for j in range(50)], tests_random, label=f"d=4, |r|={i}, random pt")
        # plt.plot([200*(j+1) for j in range(50)], tests_fixed, label=f"d=4, |r|={i}, fixed pt")
    for i in range(9):
        tests_fixed = np.ndarray(50)
        tests_random = np.ndarray(50)
        f_sys = loadmat(path(0, 8, i, 'sys'))
        f_conv = loadmat(path(0, 8, i, 'conv'))
        traces_sys = f_sys["power_traces"]
        traces_conv = f_conv["power_traces"]
        traces_sys = traces_sys - traces_sys.mean(axis=1)[:, np.newaxis]
        traces_conv = traces_conv - traces_conv.mean(axis=1)[:, np.newaxis]
        bit_arr_sys = f_sys["bit"].flatten() == 0
        bit_arr_conv = f_conv["bit"].flatten() == 0
        for j in range(50):
            traces_sys_cut = traces_sys[:200 * (j + 1), :]
            traces_conv_cut = traces_conv[:200 * (j + 1), :]
            bit_arr_sys_cut = bit_arr_sys[:200 * (j + 1)]
            bit_arr_conv_cut = bit_arr_conv[:200 * (j + 1)]
            t_value_fixed = time_t_value(traces_sys_cut[bit_arr_sys_cut, :], traces_conv_cut[bit_arr_conv_cut, :])
            t_value_random = time_t_value(traces_sys_cut[~bit_arr_sys_cut, :], traces_conv_cut[~bit_arr_conv_cut, :])
            tests_fixed[j] = np.max(t_value_fixed)
            tests_random[j] = np.max(t_value_random)
        plt.plot([200 * (j + 1) for j in range(50)], tests_random, label=f"d=8, |r|={i}, random pt")
        # plt.plot([200*(j+1) for j in range(50)], tests_fixed, label=f"d=8, |r|={i}, fixed pt")
    plt.title("maximal t-value between conv and sys encoders vs no. of traces")
    plt.xlabel("no. of traces")
    plt.ylabel("maximal t-value")
    plt.legend()
    plt.show()


def test3():
    f = loadmat(path(0, 8, 0, 'conv'))
    traces = f["power_traces"]
    traces = traces - traces.mean(axis=1)[:, np.newaxis]
    bit_arr = f["bit"].flatten() == 0
    t_value = evaluate(traces, bit_arr)
    plt.plot(t_value)
    plt.xlabel("time")
    plt.ylabel("t-value")
    plt.title("t-value of d=8, |r|=0")
    plt.show()

    f = loadmat(path(0, 8, 8, 'conv'))
    traces = f["power_traces"]
    traces = traces - traces.mean(axis=1)[:, np.newaxis]
    bit_arr = f["bit"].flatten() == 0
    t_value = evaluate(traces, bit_arr)
    plt.plot(t_value)
    plt.xlabel("time")
    plt.ylabel("t-value")
    plt.title("t-value of d=8, |r|=8")
    plt.show()


def test4():
    test4_sys = np.ndarray(50)
    test4_conv = np.ndarray(50)
    test8_sys = np.ndarray(50)
    test8_conv = np.ndarray(50)

    f_sys_4 = loadmat(path(0, 4, 4, 'sys'))
    f_conv_4 = loadmat(path(0, 4, 4, 'conv'))
    f_sys_8 = loadmat(path(0, 8, 8, 'sys'))
    f_conv_8 = loadmat(path(0, 8, 8, 'conv'))
    traces_sys_4 = f_sys_4["power_traces"]
    traces_conv_4 = f_conv_4["power_traces"]
    traces_sys_8 = f_sys_8["power_traces"]
    traces_conv_8 = f_conv_8["power_traces"]
    traces_sys_4 = traces_sys_4 - traces_sys_4.mean(axis=1)[:, np.newaxis]
    traces_conv_4 = traces_conv_4 - traces_conv_4.mean(axis=1)[:, np.newaxis]
    traces_sys_8 = traces_sys_8 - traces_sys_8.mean(axis=1)[:, np.newaxis]
    traces_conv_8 = traces_conv_8 - traces_conv_8.mean(axis=1)[:, np.newaxis]
    bit_arr_sys_4 = f_sys_4["bit"].flatten() == 0
    bit_arr_conv_4 = f_conv_4["bit"].flatten() == 0
    bit_arr_sys_8 = f_sys_8["bit"].flatten() == 0
    bit_arr_conv_8 = f_conv_8["bit"].flatten() == 0
    for j in range(50):
        traces_sys_4_cut = traces_sys_4[:200 * (j + 1), :]
        traces_conv_4_cut = traces_conv_4[:200 * (j + 1), :]
        traces_sys_8_cut = traces_sys_8[:200 * (j + 1), :]
        traces_conv_8_cut = traces_conv_8[:200 * (j + 1), :]
        bit_arr_sys_4_cut = bit_arr_sys_4[:200 * (j + 1)]
        bit_arr_conv_4_cut = bit_arr_conv_4[:200 * (j + 1)]
        bit_arr_sys_8_cut = bit_arr_sys_8[:200 * (j + 1)]
        bit_arr_conv_8_cut = bit_arr_conv_8[:200 * (j + 1)]
        t_value_sys_4 = evaluate_2nd_order(traces_sys_4_cut, bit_arr_sys_4_cut)
        t_value_conv_4 = evaluate_2nd_order(traces_conv_4_cut, bit_arr_conv_4_cut)
        t_value_sys_8 = evaluate_2nd_order(traces_sys_8_cut, bit_arr_sys_8_cut)
        t_value_conv_8 = evaluate_2nd_order(traces_conv_8_cut, bit_arr_conv_8_cut)
        test4_sys[j] = np.max(t_value_sys_4)
        test4_conv[j] = np.max(t_value_conv_4)
        test8_sys[j] = np.max(t_value_sys_8)
        test8_conv[j] = np.max(t_value_conv_8)
    plt.plot([200 * (j + 1) for j in range(50)], test4_sys, label="d=4, sys")
    plt.plot([200 * (j + 1) for j in range(50)], test4_conv, label="d=4, conv")
    plt.plot([200 * (j + 1) for j in range(50)], test8_sys, label="d=8, sys")
    plt.plot([200 * (j + 1) for j in range(50)], test8_conv, label="d=8, conv")
    plt.title("maximal order 2 t-value with max randomness vs no. of traces, |r|=d")
    plt.xlabel("no. of traces")
    plt.ylabel("maximal t-value")
    plt.legend()
    plt.show()


def test5():
    f0_1 = loadmat(path_more(500000, 0))
    f0_2 = loadmat(path_more(250000, 0))
    f1 = loadmat(path_more(750000, 1))
    f2 = loadmat(path_more(750000, 2))

    traces_f0_1 = f0_1["power_traces"]
    traces_f0_2 = f0_2["power_traces"]
    traces_f0 = np.concatenate((traces_f0_1, traces_f0_2), axis=0)
    traces_f1 = f1["power_traces"]
    traces_f2 = f2["power_traces"]
    traces_f0 = traces_f0 - traces_f0.mean(axis=1)[:, np.newaxis]
    traces_f1 = traces_f1 - traces_f1.mean(axis=1)[:, np.newaxis]
    traces_f2 = traces_f2 - traces_f2.mean(axis=1)[:, np.newaxis]
    bit_arr_f0_1 = f0_1["bit"].flatten() == 0
    bit_arr_f0_2 = f0_2["bit"].flatten() == 0
    bit_arr_f0 = np.concatenate((bit_arr_f0_1, bit_arr_f0_2), axis=0)
    bit_arr_f1 = f1["bit"].flatten() == 0
    bit_arr_f2 = f2["bit"].flatten() == 0

    tests0 = np.ndarray(30)
    tests1 = np.ndarray(30)
    tests2 = np.ndarray(30)
    for j in range(30):
        traces_f0_cut = traces_f0[:25000 * (j + 1), :]
        bit_arr_f0_cut = bit_arr_f0[:25000 * (j + 1)]
        t_value_f0 = evaluate(traces_f0_cut, bit_arr_f0_cut)
        tests0[j] = np.max(t_value_f0)
        traces_f1_cut = traces_f1[:25000 * (j + 1), :]
        bit_arr_f1_cut = bit_arr_f1[:25000 * (j + 1)]
        t_value_f1 = evaluate(traces_f1_cut, bit_arr_f1_cut)
        tests1[j] = np.max(t_value_f1)
        traces_f2_cut = traces_f2[:25000 * (j + 1), :]
        bit_arr_f2_cut = bit_arr_f2[:25000 * (j + 1)]
        t_value_f2 = evaluate(traces_f2_cut, bit_arr_f2_cut)
        tests2[j] = np.max(t_value_f2)
    plt.plot([25000 * (j + 1) for j in range(30)], tests0, label="fixed 0pt")
    plt.plot([25000 * (j + 1) for j in range(30)], tests1, label="fixed 1pt")
    plt.plot([25000 * (j + 1) for j in range(30)], tests2, label="fixed HW 4pt")

    plt.title("maximal t-value for d=8, |r|=8")
    plt.xlabel("no. of traces")
    plt.ylabel("maximal t-value")
    plt.legend()
    plt.show()


def test6():
    f_8_4 = loadmat(path_rambam(8,4))
    f_8_8 = loadmat(path_rambam(8,8))
    f_4_4 = loadmat(path_rambam(4,4))
    f_4_2 = loadmat(path_rambam(4,2))

    traces_8_4 = f_8_4["power_traces"]
    traces_8_8 = f_8_8["power_traces"]
    traces_4_4 = f_4_4["power_traces"]
    traces_4_2 = f_4_2["power_traces"]
    traces_8_4 = traces_8_4 - traces_8_4.mean(axis=1)[:, np.newaxis]
    traces_8_8 = traces_8_8 - traces_8_8.mean(axis=1)[:, np.newaxis]
    traces_4_4 = traces_4_4 - traces_4_4.mean(axis=1)[:, np.newaxis]
    traces_4_2 = traces_4_2 - traces_4_2.mean(axis=1)[:, np.newaxis]
    bit_arr_8_4 = f_8_4["bit"].flatten() == 0
    bit_arr_8_8 = f_8_8["bit"].flatten() == 0
    bit_arr_4_4 = f_4_4["bit"].flatten() == 0
    bit_arr_4_2 = f_4_2["bit"].flatten() == 0

    tests_8_4 = np.ndarray(50)
    tests_8_8 = np.ndarray(50)
    tests_4_4 = np.ndarray(50)
    tests_4_2 = np.ndarray(50)

    for j in range(50):
        traces_8_4_cut = traces_8_4[:400 * (j + 1), :]
        traces_8_8_cut = traces_8_8[:400 * (j + 1), :]
        traces_4_4_cut = traces_4_4[:400 * (j + 1), :]
        traces_4_2_cut = traces_4_2[:400 * (j + 1), :]
        bit_arr_8_4_cut = bit_arr_8_4[:400 * (j + 1)]
        bit_arr_8_8_cut = bit_arr_8_8[:400 * (j + 1)]
        bit_arr_4_4_cut = bit_arr_4_4[:400 * (j + 1)]
        bit_arr_4_2_cut = bit_arr_4_2[:400 * (j + 1)]
        t_value_8_4 = evaluate(traces_8_4_cut, bit_arr_8_4_cut)
        t_value_8_8 = evaluate(traces_8_8_cut, bit_arr_8_8_cut)
        t_value_4_4 = evaluate(traces_4_4_cut, bit_arr_4_4_cut)
        t_value_4_2 = evaluate(traces_4_2_cut, bit_arr_4_2_cut)
        tests_8_4[j] = np.max(t_value_8_4)
        tests_8_8[j] = np.max(t_value_8_8)
        tests_4_4[j] = np.max(t_value_4_4)
        tests_4_2[j] = np.max(t_value_4_2)
    plt.plot([400 * (j + 1) for j in range(50)], tests_8_4, label="d=8, |r|=4")
    plt.plot([400 * (j + 1) for j in range(50)], tests_8_8, label="d=8, |r|=8")
    plt.plot([400 * (j + 1) for j in range(50)], tests_4_4, label="d=4, |r|=4")
    plt.plot([400 * (j + 1) for j in range(50)], tests_4_2, label="d=4, |r|=2")
    plt.title("Maximal t-value for RAMBAM vs. no of Traces")
    plt.xlabel("no. of traces")
    plt.ylabel("maximal t-value")
    plt.legend()
    plt.show()


if __name__ == '__main__':
    # test2()
    # test1()
    # test3()
    # test4()
    # test5()
    test6()