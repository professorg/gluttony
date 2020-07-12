# Block Properties

## ID system

This pack uses a categorical ID system. Block IDs will have categories
represented by certain digits in particular positions denoting whether a block
is part of a particular category. The format was designed to be readable in
decimal, while being relatively information-dense. Since most of the categorical
data will be using only octal digits, the digits 8 and 9 will be rarely used.

### Categories

Most categories will be binary switches (e.g., is the block a fluid?). Groups of
3 binary switches will be represented in a single digit as an octal 3-bit pair:

    101         =>      4*1 + 2*0 + 1*1 = 5
    ^^^                                   ^
    ||\= 1st category        Final Digit =/
    |\== 2nd category
    \=== 3rd category

Digits may also represent discrete categories like color:

    0: Colorless
    1: Red
    2: Orange
    3: Yellow
    ...

### Overall Format

Each ID will have digits in fixed positions representing the categorical data,
plus two digits reserved at the end for disambiguation of blocks with the same
categorical data:

    o: octal            [0-7]
    c: categorical      \d
    d: disambiguation   \d
    (o|c)+dd

### Examples

| digit |    categories     |
| ----- | ----------------- |
|  0-1  | disambiguation    |
|  2.1  | foliage?          |
|  2.2  | sways?            |
|  2.3  | solid?            |
|  3    | color             |

Color key:
| digit |   color   |
| ----- | --------- |
|   0   | N/A       |
|   1   | Red       |
|   2   | Orange    |
|   3   | Yellow    |
|   4   | Green     |
|  ...  |    ...    |
|   9   | Magenta   |

    block.0700=minecraft:oak_leaves
    block.0701=minecraft:birch_leaves
    block.0702=minecraft:spruce_leaves
    ...
    block.0300=minecraft:grass
    block.0301=minecraft:vine
    ...
    block.0500=minecraft:brown_mushroom_block
    block.0501=minecraft:red_mushroom_block
    ...
    block.1400=minecraft:red_wool
    block.1401=minecraft:red_concrete
    block.2400=minecraft:orange_wool
    block.2401=minecraft:orange_concrete
    ...

## Usage

Flags will be checked with mod and integer comparison. For example:

    // Extract digit value from id
    // id:      the block id
    // digit:   digit number, starting at 1 for the rightmost digit
    // returns: the digit at the given position
    int extract(int id, int digit) {
        return mod(id, pow(10, digit)) / pow(10, digit - 1);
    }

    // Disambiguation
    // id:      the block id
    // returns: the disambiguation id
    int disambiguation(int id) {
        return mod(id, 100);
    }

    // Check binary switch in id
    // id:          the block id
    // digit:       digit number, starting at 1 for the rightmost digit
    // category:    category index, starting at 0 for the least significant
    // returns:     whether the block id is in the category
    bool check(int id, int digit, int category) {
        return extract(id, digit) / pow(2, category) != 0;
    }

    // Check discrete category in id
    // This is basically equivalent to the extract function
    // id:          the block id
    // digit:       digit number, starting at 1 for the rightmost digit
    // returns:     the value for the discrete category
    int get(int id, int digit) {
        return extract(id, digit);
    }

