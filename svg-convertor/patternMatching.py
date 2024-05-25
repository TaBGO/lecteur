#!/usr/bin/env python
# coding: utf-8

import re
from blocStructure import Bloc


def get_inputs(input, pattern):
    inputs = []
    for m in input.split('],"'):
        if(len(m) > 0):
            value = re.search(pattern, m)
            if(value != None):
                value = value.group(1)
                inputs.append(value)
    return inputs

def createDictionnary(fileReading):
    blocs = {}
    for m in re.finditer(r'"(.+?)":{(?:"mutation":{(.*?)},)?"opcode":(.*?),"inputs":{(.*?)}(.*?),"fields":{(.*?)},"shadow"(.+?)(?:,"x":(\d+),"y":(\d+))?}', fileReading):
        start = m.start()
        end = m.end()
        bloc = fileReading[start:end]
        name = re.search('"(.+?)"', bloc).group(1)
        opcode = re.search('"opcode":"(.+?)"', bloc).group(1)
        next = re.search('"next":(?:"|)(.+?)(?:"|),"parent',bloc).group(1)
        parent = re.search('"parent":(?:"|)(.+?)(?:"|),',bloc).group(1)
        inputs = get_inputs(re.search('"inputs":{(.*?)},', bloc).group(1), r',"(.+?)"')
        fields = get_inputs(re.search('"fields":{(.*?)},"shadow', bloc).group(1), r'\["(.+?)",')
        object = Bloc(opcode,parent, next, inputs, fields)
        blocs.update([(name, object)])
    return blocs

def advanceBlock(fileReading):
    fileReading = fileReading[fileReading.find("block")+1:]
    fileReading = fileReading[fileReading.find("block"):]
    return fileReading

def get_first_blocks(fileReading):
    first = []
    for m in re.finditer('[^"]+(?=":{"opcode":"event_|":{"opcode":"event_)', fileReading):
        start = m.start()
        end = m.end()
        name = fileReading[start:end]
        first.append(name)
    return first

def recognize_X_size(fileReading):
    return re.search('viewBox="0 0 (.+?) ', fileReading).group(1)

def recognize_Y_size(xSize, fileReading):
    return re.search('viewBox="0 0 ' + xSize + ' (.+?)"', fileReading).group(1)

def get_location(text):
    loc = re.search(r'location=(.+?) ', text)
    if(loc != None):
        return loc.group(1)
    else:
        return None

def get_x(text):
    x = re.search(r'x=(.+?) ', text)
    if(x != None):
        return int(x.group(1))
    else:
        return None

def get_y(text):
    y = re.search(r'y=(.+?) ', text)
    if(y != None):
        return int(y.group(1))
    else:
        return None

def get_scale(text):
    scale = re.search(r'scale=(.+?) ', text)
    if(scale != None):
        return float(scale.group(1))
    else:
        return None

    
