import cv2
import os

img = cv2.imread('FullSizeRender.png')

path = 'icons'
os.makedirs(path, exist_ok=True)
# Resize image

method = cv2.INTER_LANCZOS4

#20x20
img20 = cv2.resize(img, (20, 20), interpolation=method)
cv2.imwrite(path+'/20x20.png', img20)

#29x29
img29 = cv2.resize(img, (29, 29), interpolation=method)
cv2.imwrite(path+'/29x29.png', img29)

#58x58
img58 = cv2.resize(img, (58, 58), interpolation=method)
cv2.imwrite(path+'/58x58.png', img58)

#40x40
img40 = cv2.resize(img, (40, 40), interpolation=method)
cv2.imwrite(path+'/40x40.png', img40)

#80x80
img80 = cv2.resize(img, (80, 80), interpolation=method)
cv2.imwrite(path+'/80x80.png', img80)

#60x60
img60 = cv2.resize(img, (60, 60), interpolation=method)
cv2.imwrite(path+'/60x60.png', img60)

#120x120
img120 = cv2.resize(img, (120, 120), interpolation=method)
cv2.imwrite(path+'/120x120.png', img120)

#76x76
img76 = cv2.resize(img, (76, 76), interpolation=method)
cv2.imwrite(path+'/76x76.png', img76)

#152x152
img152 = cv2.resize(img, (152, 152), interpolation=method)
cv2.imwrite(path+'/152x152.png', img152)

#83x83
img83 = cv2.resize(img, (83, 83), interpolation=method)
cv2.imwrite(path+'/83x83.png', img83)

#87x87
img87 = cv2.resize(img, (87, 87), interpolation=method)
cv2.imwrite(path+'/87x87.png', img87)

#167x167
img167 = cv2.resize(img, (167, 167), interpolation=method)
cv2.imwrite(path+'/167x167.png', img167)

#180x180
img180 = cv2.resize(img, (180, 180), interpolation=method)
cv2.imwrite(path+'/180x180.png', img180)

#1024x1024
img1024 = cv2.resize(img, (1024, 1024), interpolation=method)
cv2.imwrite(path+'/1024x1024.png', img1024)


