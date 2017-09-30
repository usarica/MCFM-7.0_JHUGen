      subroutine gen5from4(q,z,rtalpha,phit,p,jac,*)
      implicit none
      include 'types.f'
c----jac is the total wt of the whole business (4) and (5 from 4)
      
      include 'constants.f'
      include 'nf.f'
      include 'mxpart.f'
      include 'cplx.h'
      include 'debug.f'
      integer:: nmin,nmax,j,iseed,k
      real(dp):: p(mxpart,4),q(mxpart,4),z,rtalpha,phit,
     & wt5_4,msq(-nf:nf,-nf:nf)
      real(dp):: sum(0:8),wtc(8),apweight(8),jac,ran0,myran
      common/apwt/apweight
      common/nmin/nmin
      common/nmax/nmax
      data iseed/1768/
      integer,parameter:: i1(8)=(/1,2,1,1,2,2,5,6/)
      integer,parameter:: i2(8)=(/2,1,5,6,5,6,6,5/)
      
c      call writeout(p)     

      do j=1,7
      do k=1,4
      p(j,k)=q(j,k)
      enddo
      enddo
 
      sum(nmin-1)=0._dp

      do j=nmin,nmax
      apweight(j)=1._dp/real(nmax-nmin+1,dp)
      sum(j)=sum(j-1)+apweight(j)
      if (debug) then
      write(6,*) 'j',j 
      write(6,*) 'apweight(j)',apweight(j) 
      write(6,*) 'sum(j)',sum(j) 
      endif
      enddo
  
      myran=ran0(iseed)

      do j=nmin,nmax
      if ((myran > sum(j-1)) .and. (myran < sum(j))) then
c---genrad is a switchyard routine routing to genrii,genrif,genrff
      call genrad(p,i1(j),i2(j),7,z,rtalpha,phit,wt5_4,*999)
c---although genrad returns wt5_4 we shall not use it 
c---in this step we have generated the new p's (only one set)
c---only one option is pursued in this do-loop 
      endif      
      enddo

c---Sum over channels
c---Initialize jac
      jac=0._dp
      do j=nmin,nmax
         if ((j == 1) .or. (j == 2)) 
     &      call genii(j,p,wtc(j),msq)
         if ((j == 3) .or. (j == 4)) 
     &      call genff(j-2,p,wtc(j),msq)
         if ((j == 5) .or. (j == 6) .or. (j == 7) .or. (j == 8))
     &      call genif(j-4,p,wtc(j),msq)
        jac=jac+apweight(j)/wtc(j)
      enddo
      jac=1._dp/jac


      return 

 999  jac=0._dp
      return 1
      end

