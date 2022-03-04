#ifndef CDE_PROXY_H
#define CDE_PROXY_H

#ifdef __cplusplus

class ysdq_cde_proxy
{
public:
    virtual void invoker(const int& tag, const char *data) = 0;
protected:
    ysdq_cde_proxy(){}
    virtual ~ysdq_cde_proxy(){}
};

#endif

#endif //CDE_PROXY_H
