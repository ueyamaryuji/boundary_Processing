import numpy as np
import re
import sys


class MkTwist:
    def __init__(self, sigma):
        self.sigma = sigma
        self.read_poscar_0()
        self.expand_lat()
        self.theta = np.arctan2(1.0, self.sigma)
        self.angle = self.theta / np.pi * 180.0
        self.rotate_lat(self.theta)
        self.rotate_pos(self.theta)
        self.print_poscar()
        self.save_poscar('./')
        self.save_poscar('./sketch_twist/data/')

    def read_poscar_0(self):
        with open('POSCAR_0', 'r')as f:
            lines = f.readlines()
        self.lat = np.zeros((3, 3))
        # 格子定数を初期化
        for i in range(3):
            self.lat[i][i] = re.findall(r'\d\.\d*', lines[i + 2])[i]
        # poscar_0から格子定数を読み取る
        self.n_atom = int(lines[5])
        self.pos = np.zeros((self.n_atom, 3))
        # n_atomの数だけ(0,0,0)で初期化
        for i in range(self.n_atom):
            poss = re.findall(r'\d\.\d*', lines[i + 7])
            for j in range(3):
                self.pos[i][j] = poss[j]
        # poscar_0の原子位置を読み取る

    def expand_lat(self, n_lat=8):
        # z軸方向を4倍
        self.lat[2][2] = n_lat * self.lat[2][2]
        self.expand_pos = []
        for i in range(-2, 5):
            for j in range(-2, 5):
                for k in range(0, n_lat):
                    for pos in self.pos:
                        sel = [i, j, k]
                        tmp = []
                        for m in range(3):
                            tmp.append((pos[m] + sel[m]) / self.lat[m][m])
                        self.expand_pos.append(tmp)

        self.n_atom = len(self.expand_pos)

    def r_matrix(self, theta):
        arr = np.matrix([[np.cos(theta), -np.sin(theta), 0],
                         [np.sin(theta), np.cos(theta), 0],
                         [0, 0, 1]])
        return arr

    def rotate_lat(self, theta):
        if self.sigma % 2 == 0:
            div = 1.0
        else:
            div = 2.0

        self.lat[0] = np.dot(self.r_matrix(theta), np.array([self.sigma / div, -1.0 / div, 0.0]))
        self.lat[1] = np.dot(self.r_matrix(theta), np.array([1.0 / div, self.sigma / div, 0.0]))

    def add_rotate_pos(self, theta, pos):
        pos_new = np.array(np.dot(self.r_matrix(theta), np.array(pos)))[0]
        if pos_new[0] >= 0 and pos_new[0] < self.x_lat and pos_new[1] >= 0 and pos_new[1] < self.y_lat:
            x, y, z = pos_new
            self.rotate_pos.append([x / self.x_lat, y / self.y_lat, z])

    def rotate_pos(self, theta):
        self.rotate_pos = []
        for pos in self.expand_pos:
            self.x_lat = self.lat[0][0]
            self.y_lat = self.lat[1][1]
            if pos[2] < 0.5:
                self.add_rotate_pos(theta, pos)
            else:
                self.add_rotate_pos(-theta, pos)

    def print_poscar(self):
        self.cont = ''
        self.cont += (f'n_sigma={self.sigma:4d}, theta={self.theta:8.4f}, angle={self.angle:8.4f}, twist boundary\n')
        self.cont += ("4.0414\n")
        for x in self.lat:
            self.cont += (f'{x[0]:15.10f} {x[1]:15.10f} {x[2]:15.10f}\n')
        n_atom = len(self.rotate_pos)
        self.cont += (f'{n_atom}\nDirect\n')
        for x in sorted(self.rotate_pos, key=lambda x: x[2]):
            self.cont += (f'{x[0]:15.10f} {x[1]:15.10f} {x[2]:15.10f}\n')
        print(self.cont)

    def save_poscar(self, dir):
        with open(dir + 'POSCAR', 'w+')as f:
            f.writelines(self.cont)


if __name__ == '__main__':
    if len(sys.argv) == 2:
        sigma = int(sys.argv[1])
    else:
        sigma = 3
    MkTwist(sigma)
