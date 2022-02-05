---
external help file: PowershellForDocker-help.xml
Module Name: PowershellForDocker
online version: https://github.com/dcjulian29/scripts-powershell/blob/main/Modules/PowershellForDocker/docs/Optimize-Docker.md
schema: 2.0.0
---

# Optimize-Docker

## SYNOPSIS

Remove unused Docker data.

## SYNTAX

```powershell
Optimize-Docker [-Force]
```

## DESCRIPTION

Remove all unused containers, networks, images (both dangling and unreferenced).

## EXAMPLES

### Example 1

```powershell
PS C:\> Optimize-Docker
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache

Are you sure you want to continue? [y/N] y
Deleted Images:
untagged: dcjulian29/ansible@sha256:f41f968b59bbd45131074ca5fab29cca3bd373386ed0a4faf9a9d3e6b97d9172
deleted: sha256:e7834b72c6ebdd9909f36ef8c3ca6054c9b7a272cf92a8236a4c9000ea67f226
untagged: dcjulian29/ansible@sha256:20e41f352e0ceddaf251e9c426432e8b64981a50ed3bb37e6688fdd25649be82
deleted: sha256:e1acbbda299a0c6a80f42a68b829cf3ffb8e410f5831a6869e10a598bcae37c0
untagged: dcjulian29/ansible@sha256:d6eb7c4d7b0e3c49b89c2a3fd14e0d556fca16403687d831999d4228ad6b6386
deleted: sha256:aea3f80e0709fb747277191fd228f50dd80a0a47f8c306a82d8a8e1baf0222d5

Deleted build cache objects:
2kuck509ygswyfenqn13r0fi8
o52b6f82bgtg3w74uo13yk1hh
t9wfulszbmtsjn0fh9bnh37r0
w5ayx8vn1insvu8kor7bx91z5
ov5cov61mzrxshwfds3j1zo20
0kfucqr8iilqjsizmy78y6tni
mtvnywj121vlb98i3nlpbyio2
ybmlk1ssk7pycdq5com2besrq
jjhlqzomhni2mnk31qq09cslj
siq1r9x34zf6ck189d5u93tu1
slmqz4kr1uzyvub84n315zc18
tv5aabb1o6a8zh2z14j4mrugn
ict67ak5soqy1m7nc4zspgskh
l12f6njjarhzurthpfz0ww5p4
m0tqmwie5r1tnbrsqqv1x09a2
k8gpua3bmre9lua6tjt8rekdp
f7diq8omtnkonau1nbwkf0e4j
ylcrt22ygudhiszy3ng4y3510
mnv8ha0asshtvvic3qesuutgy
q8yxew89cl9mr8hhsztkxrt54
t65jmctf1kh0jmo5n9bl4nbaf
cw7f377q774xdkdqx7u7bucmw
juk9cigxyf5cv3tx98z9teklb
lro1k8dnrq3u25u9zz50ndcb2
ms23mxzt2b620tbjidndgjhk0
v8mz37t0wanfxtzn9ibkyx5nw
6knlu1eszz3bv6zuvu2vq2vfq
icn1mv3v9j7ihcubmwtk8euw2
yh2id58bzgm3iybjibckjmmd0
0ultbu872jl4vzjubrhm4ro6l
7mji4deam61in36rakssfik3m
iytfpsmuyxzalbhiyyg44i1wy
rfsdce5l7poh8y4xcbmzog4zw
bkhqmsutzb94dity5c7fc79rl
enbzf5waok7lachxk35vvunxy
uhennz8lzbbu0t24vfzn6ep27
zkzmy5x3t0i1do4togovvke44
zlieop214rvayf49jx4tzc8f5
6p3aqbctoxe7hlqhisd7uj19l
zkb9cvje54p61plkgcomr2en2
of81u77ynlch8rczn5jz06i60
pe6dfkaqqao7ex430m6jw6kuj
02fmte17sa415irdx8tj0ld91
5ktpbk9w7s8pl2brew34g8ji5
n10hjo7l85qjhhta7l9pg3hpc
kkb53haiij56rtwalrjbfbs57
t3c565z4bqarqxyfia4o7dzmk
nblub8vz713ku9b436zbnjoad
tllah89mxpytqy6xybgtk8w7w
mrfzlz6qyr0tr7irgeu0timsf
j0vz1sqg3pkf8kb34g356ec4v
7xwaqdfyxo2cq03qmruaweg1n
cis5n0zo0wrgp1oxfkhqzzrw9
42z7ic3oq8x0irrfl6pbs6krd
ixtubla8imfhnr900450vz368
4a6lkw431gs0llm99cirtyu57
ccshns7ojzq0fhzk6ooyhga6x
rh0m0b5yilowzr4a5waq7t0d2
nfne6ywo2pgriz0clwhv8tph9
dcnljj6q0ez0ugzszpzgr3i5t
kivtrqogo1p3r1xfkut95ec06
7whcymomkxyokjmgqq7ox5wnh
wtk5vvbwjdctgfhjsztorlks8
aqvgyfrgea40wxcsmq6p0hoh3
x6y7qyyj7hsa409lmziseps19

Total reclaimed space: 20.62GB
```

This example removed unused Docker data.

## PARAMETERS

### -Force

Specify to not prompt for confirmation.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```
