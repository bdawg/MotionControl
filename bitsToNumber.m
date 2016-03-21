function [data] = bitsToNumber(d3,d4,d5,d6)
    data = (d6*256^3)+(d5*256^2)+(d4*256)+d3;