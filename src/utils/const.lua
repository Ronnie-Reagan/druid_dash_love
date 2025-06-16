local const = {}

const.MAPFILE_PATH = "assets/mapfiles/"
const.TILEMAP_1_PATH = "assets/mapfiles/tilemap_1"
const.TILE_GRID_SIZE = 16
const.DIRECTION = {
    LEFT = 1,
    RIGHT = 2,
    UP = 3,
    DOWN = 4,
    NONE = 5
}
const.DIRECTION_TABLE = {{-1,0},{1,0},{0,-1},{0,1},{0,0}}
const.REVERSE_DIRECTION_TABLE = {{1,0},{-1,0},{0,1},{0,-1},{0,0}}
const.WALL_TILES = {2,3}
const.WATER_TILES = {22,23,24,28,29,30,34,35,36}

return const