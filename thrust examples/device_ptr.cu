#include <thrust/transform_reduce.h>
#include <thrust/device_vector.h>
#include <thrust/pair.h>
#include <thrust/random.h>
#include <thrust/extrema.h>

// This example shows how to compute a bounding box
// for a set of points in two dimensions.

struct point2d
{
  float x, y;
  
  __host__ __device__
  point2d() : x(0), y(0) {}
  
  __host__ __device__
  point2d(float _x, float _y) : x(_x), y(_y) {}
};

// bounding box type
struct bbox
{
  // construct an empty box
  __host__ __device__
  bbox() {}

  // construct a box from a single point
  __host__ __device__
  bbox(const point2d &point)
    : lower_left(point), upper_right(point)
  {}

  // construct a box from a pair of points
  __host__ __device__
  bbox(const point2d &ll, const point2d &ur)
    : lower_left(ll), upper_right(ur)
  {}

  point2d lower_left, upper_right;
};

// reduce a pair of bounding boxes (a,b) to a bounding box containing a and b
struct bbox_reduction : public thrust::binary_function<bbox,bbox,bbox>
{
  __host__ __device__
  bbox operator()(bbox a, bbox b)
  {
    // lower left corner
    point2d ll(thrust::min(a.lower_left.x, b.lower_left.x), thrust::min(a.lower_left.y, b.lower_left.y));
    
    // upper right corner
    point2d ur(thrust::max(a.upper_right.x, b.upper_right.x), thrust::max(a.up